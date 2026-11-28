// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {IMigratableAsset} from "../interfaces/IMigratableAsset.sol";
import {Kinds} from "../core/Kinds.sol";

/// @title RealEstateToken
/// @notice One contract run by the Legal Affairs Bureau (provisional implementation). Each
///         token is a parcel, building, unit or co-ownership share; moving the token is the
///         transfer of the right. No lot number on-chain, only a salted hash.
///
///         Provisional simplification: the spec's off-chain signatures (agent, lender, recipient,
///         bureau) are replaced by on-chain approval calls made before the transfer.
///         - Individual owners need one approval from a currently registered agent of the token.
///         - Individual recipients must have named at least one agent for the token.
///         - A lien needs the lender's consent; a permission parcel needs the bureau's approval.
///         - Holders that lost their registration, or are suspended, cannot transfer; their tokens
///           move only by the successor-migration contract (R3.2) or a forced transfer.
/// @dev Spec: docs/state-design/real-estate/README.md; ADRs 0029, 0032 (R1.3, R2.2, R3.2, R3.9).
///      The foreign-company check (foreign flag in CorporateRegistration, foreign control > 50%)
///      is left to the bureau's off-chain review in this provisional version.
contract RealEstateToken is ERC721Enumerable, AccessControl, IMigratableAsset {
    using SafeERC20 for IERC20;

    bytes32 public constant BUREAU_ROLE = keccak256("BUREAU_ROLE");
    bytes32 public constant MIGRATOR_ROLE = keccak256("MIGRATOR_ROLE");

    struct Parcel {
        bytes32 parcelHash;
        uint32 shareNumerator;
        uint32 shareDenominator;
        bool needsApproval;
        address lender; // zero = no lien
        bytes32 lienContractHash;
    }

    struct Settlement {
        address buyer;
        address seller;
        uint256 price;
        uint64 deadline;
        bool closed;
        uint256[] tokenIds;
    }

    IOfficialContractRegistry public immutable registry;
    IERC20 public immutable jpy;

    mapping(uint256 tokenId => Parcel) public parcels;
    mapping(uint256 tokenId => address[]) private _agents;
    /// @notice Agents a prospective recipient has named for a token (recipient's own call).
    mapping(uint256 tokenId => mapping(address recipient => address[])) private _namedAgents;
    mapping(uint256 tokenId => mapping(address to => bool)) public agentApproved;
    mapping(uint256 tokenId => mapping(address to => bool)) public lenderConsented;
    mapping(uint256 tokenId => mapping(address to => bool)) public bureauApproved;
    mapping(uint256 tokenId => bytes32 agentsHash) public agentChangeApproved;
    mapping(uint256 id => Settlement) private _settlements;
    uint256 public settlementCount;
    uint256 private _nextId = 1;

    event Minted(uint256 indexed tokenId, bytes32 parcelHash, uint32 shareNumerator, uint32 shareDenominator);
    event AgentsSet(uint256 indexed tokenId, address[] agents);
    event Transferred(uint256 indexed tokenId, address indexed from, address indexed to);
    event ForcedTransfer(uint256 indexed tokenId, address indexed to, bytes32 decisionHash, bytes32 kind);
    event LienSet(uint256 indexed tokenId, address indexed lender, bytes32 contractHash);
    event LienReleased(uint256 indexed tokenId);
    event SettlementOpened(uint256 indexed id, address indexed buyer, address indexed seller, uint256 price);
    event SettlementClosed(uint256 indexed id, bool completed);

    error DirectTransferDisabled();
    error NotOwner();
    error NotEligibleOwner(address account);
    error RecipientNeedsAgent();
    error AgentApprovalMissing();
    error LenderConsentMissing();
    error BureauApprovalMissing();
    error HolderInactive();
    error NotAgent();
    error NotLender();
    error BadAgents();
    error SettlementInvalid();

    constructor(address bureau, IOfficialContractRegistry registry_, IERC20 jpy_) ERC721("Real Estate", "REAL") {
        registry = registry_;
        jpy = jpy_;
        _grantRole(DEFAULT_ADMIN_ROLE, bureau);
        _grantRole(BUREAU_ROLE, bureau);
    }

    // ---------------- issuance ----------------

    function mint(address to, Parcel calldata parcel, address[] calldata agents)
        external
        onlyRole(BUREAU_ROLE)
        returns (uint256 tokenId)
    {
        _requireEligible(to);
        tokenId = _nextId++;
        parcels[tokenId] = parcel;
        _mint(to, tokenId);
        _setAgents(tokenId, to, agents);
        emit Minted(tokenId, parcel.parcelHash, parcel.shareNumerator, parcel.shareDenominator);
    }

    // ---------------- approvals made before a transfer ----------------

    /// @notice The prospective recipient names its agents for this token (its own signature).
    function nameAgents(uint256 tokenId, address[] calldata agents) external {
        _namedAgents[tokenId][msg.sender] = agents;
    }

    function approveAsAgent(uint256 tokenId, address to) external {
        if (!_isValidAgent(tokenId, msg.sender)) revert NotAgent();
        agentApproved[tokenId][to] = true;
    }

    function consentAsLender(uint256 tokenId, address to) external {
        if (parcels[tokenId].lender != msg.sender) revert NotLender();
        lenderConsented[tokenId][to] = true;
    }

    function approveAsBureau(uint256 tokenId, address to) external onlyRole(BUREAU_ROLE) {
        bureauApproved[tokenId][to] = true;
    }

    // ---------------- transfer and settlement ----------------

    function transferParcel(uint256 tokenId, address to) external {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();
        _transferChecked(tokenId, msg.sender, to);
    }

    /// @notice The buyer deposits the price for a list of the seller's tokens.
    function openSettlement(address seller, uint256[] calldata tokenIds, uint256 price, uint64 deadline)
        external
        returns (uint256 id)
    {
        jpy.safeTransferFrom(msg.sender, address(this), price);
        id = ++settlementCount;
        _settlements[id] = Settlement(msg.sender, seller, price, deadline, false, tokenIds);
        emit SettlementOpened(id, msg.sender, seller, price);
    }

    /// @notice The seller closes: every token moves and the money is released, atomically.
    function settle(uint256 id) external {
        Settlement storage s = _settlements[id];
        if (s.closed || msg.sender != s.seller || block.timestamp > s.deadline) revert SettlementInvalid();
        s.closed = true;
        for (uint256 i; i < s.tokenIds.length; ++i) {
            if (ownerOf(s.tokenIds[i]) != s.seller) revert NotOwner();
            _transferChecked(s.tokenIds[i], s.seller, s.buyer);
        }
        jpy.safeTransfer(s.seller, s.price);
        emit SettlementClosed(id, true);
    }

    function withdrawSettlement(uint256 id) external {
        Settlement storage s = _settlements[id];
        if (s.closed || msg.sender != s.buyer || block.timestamp <= s.deadline) revert SettlementInvalid();
        s.closed = true;
        jpy.safeTransfer(s.buyer, s.price);
        emit SettlementClosed(id, false);
    }

    // ---------------- agents ----------------

    function approveAgentChange(uint256 tokenId, address[] calldata newAgents) external {
        if (!_isValidAgent(tokenId, msg.sender)) revert NotAgent();
        agentChangeApproved[tokenId] = keccak256(abi.encode(newAgents));
    }

    function changeAgents(uint256 tokenId, address[] calldata newAgents) external {
        address owner = ownerOf(tokenId);
        if (owner != msg.sender) revert NotOwner();
        if (_isIndividual(owner) && agentChangeApproved[tokenId] != keccak256(abi.encode(newAgents))) {
            revert AgentApprovalMissing();
        }
        delete agentChangeApproved[tokenId];
        _setAgents(tokenId, owner, newAgents);
    }

    /// @notice No valid agent left: a registrar of the owner's kind (the municipality) confirms
    ///         new agents (as the light path).
    function resetAgentsByRegistrar(uint256 tokenId, address[] calldata newAgents) external {
        address owner = ownerOf(tokenId);
        if (!registry.isRegistrarOfKind(owner, msg.sender)) revert NotAgent();
        address[] storage current = _agents[tokenId];
        for (uint256 i; i < current.length; ++i) {
            if (registry.isRegistered(current[i])) revert BadAgents(); // a valid agent remains
        }
        _setAgents(tokenId, owner, newAgents);
    }

    function agentsOf(uint256 tokenId) external view returns (address[] memory) {
        return _agents[tokenId];
    }

    // ---------------- mortgages ----------------

    /// @notice The lender calls with the owner's and an agent's prior approval for the lender.
    function setLien(uint256 tokenId, bytes32 contractHash) external {
        address owner = ownerOf(tokenId);
        if (!agentApproved[tokenId][msg.sender] && _isIndividual(owner)) revert AgentApprovalMissing();
        delete agentApproved[tokenId][msg.sender];
        parcels[tokenId].lender = msg.sender;
        parcels[tokenId].lienContractHash = contractHash;
        emit LienSet(tokenId, msg.sender, contractHash);
    }

    function releaseLien(uint256 tokenId) external {
        if (parcels[tokenId].lender != msg.sender) revert NotLender();
        parcels[tokenId].lender = address(0);
        parcels[tokenId].lienContractHash = 0;
        emit LienReleased(tokenId);
    }

    // ---------------- transfers without the owner's signature ----------------

    /// @notice Auction, judgment, prescription, expropriation, forced sale. The decision hash
    ///         refers to CaseRecordRegistry (or an anchored expropriation decision); it is not
    ///         checked on-chain. A foreclosure clears the lien.
    function forceTransfer(uint256 tokenId, address to, bytes32 decisionHash, bytes32 kind, address[] calldata agents)
        external
        onlyRole(BUREAU_ROLE)
    {
        _requireEligible(to);
        address from = ownerOf(tokenId);
        if (kind == keccak256("Foreclosure")) {
            parcels[tokenId].lender = address(0);
            parcels[tokenId].lienContractHash = 0;
        }
        _moveRaw(tokenId, from, to, agents);
        emit ForcedTransfer(tokenId, to, decisionHash, kind);
    }

    /// @inheritdoc IMigratableAsset
    /// @dev `data` = abi.encode(address[][] agentsPerSuccessor). With several successors, each
    ///      token is re-issued as co-ownership share tokens (R3.9).
    function migrateAll(address from, address[] calldata successors, uint16[] calldata sharesBps, bytes calldata data)
        external
        onlyRole(MIGRATOR_ROLE)
    {
        address[][] memory agentsPer = data.length == 0 ? new address[][](successors.length) : abi.decode(data, (address[][]));
        uint256 count = balanceOf(from);
        for (uint256 n; n < count; ++n) {
            uint256 tokenId = tokenOfOwnerByIndex(from, 0);
            if (successors.length == 1) {
                _moveRaw(tokenId, from, successors[0], agentsPer[0]);
            } else {
                _splitToShares(tokenId, from, successors, sharesBps, agentsPer);
            }
        }
    }

    // ---------------- internal ----------------

    function _transferChecked(uint256 tokenId, address from, address to) private {
        if (!registry.isRegistered(from) || registry.isSuspended(from)) revert HolderInactive();
        _requireEligible(to);
        if (_isIndividual(from) && !agentApproved[tokenId][to]) revert AgentApprovalMissing();
        Parcel storage p = parcels[tokenId];
        if (p.lender != address(0) && !lenderConsented[tokenId][to]) revert LenderConsentMissing();
        if (p.needsApproval && !bureauApproved[tokenId][to]) revert BureauApprovalMissing();
        address[] memory named = _namedAgents[tokenId][to];
        delete agentApproved[tokenId][to];
        delete lenderConsented[tokenId][to];
        delete bureauApproved[tokenId][to];
        delete _namedAgents[tokenId][to];
        _moveRaw(tokenId, from, to, named);
    }

    function _moveRaw(uint256 tokenId, address from, address to, address[] memory agents) private {
        _transfer(from, to, tokenId);
        _setAgents(tokenId, to, agents);
        emit Transferred(tokenId, from, to);
    }

    function _splitToShares(
        uint256 tokenId,
        address from,
        address[] calldata successors,
        uint16[] calldata sharesBps,
        address[][] memory agentsPer
    ) private {
        Parcel memory p = parcels[tokenId];
        _burn(tokenId);
        delete parcels[tokenId];
        delete _agents[tokenId];
        for (uint256 i; i < successors.length; ++i) {
            _requireEligible(successors[i]);
            uint256 newId = _nextId++;
            Parcel memory q = p;
            q.shareNumerator = uint32(uint256(p.shareNumerator) * sharesBps[i]);
            q.shareDenominator = uint32(uint256(p.shareDenominator) * 10_000);
            parcels[newId] = q;
            _mint(successors[i], newId);
            _setAgents(newId, successors[i], agentsPer[i]);
            emit Minted(newId, q.parcelHash, q.shareNumerator, q.shareDenominator);
            emit Transferred(newId, from, successors[i]);
        }
    }

    function _setAgents(uint256 tokenId, address owner, address[] memory agents) private {
        if (_isIndividual(owner) && agents.length == 0) revert RecipientNeedsAgent();
        for (uint256 i; i < agents.length; ++i) {
            if (agents[i] == owner || !registry.isRegistered(agents[i])) revert BadAgents();
        }
        _agents[tokenId] = agents;
        emit AgentsSet(tokenId, agents);
    }

    function _isValidAgent(uint256 tokenId, address account) private view returns (bool) {
        if (!registry.isRegistered(account) || registry.isSuspended(account)) return false;
        address[] storage a = _agents[tokenId];
        for (uint256 i; i < a.length; ++i) {
            if (a[i] == account) return true;
        }
        return false;
    }

    function _isIndividual(address account) private view returns (bool) {
        return registry.isRegisteredAs(account, Kinds.RESIDENT) || registry.isRegisteredAs(account, Kinds.NATIONAL_ABROAD);
    }

    function _requireEligible(address account) private view {
        bool ok = registry.isRegisteredAs(account, Kinds.RESIDENT) || registry.isRegisteredAs(account, Kinds.NATIONAL_ABROAD)
            || registry.isRegisteredAs(account, Kinds.CORPORATION) || registry.isRegisteredAs(account, Kinds.PUBLIC_CONTRACT);
        if (!ok) revert NotEligibleOwner(account);
    }

    // ---------------- ERC721 plumbing ----------------

    function transferFrom(address, address, uint256) public pure override(ERC721, IERC721) {
        revert DirectTransferDisabled();
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override(ERC721, IERC721) {
        revert DirectTransferDisabled();
    }

    function approve(address, uint256) public pure override(ERC721, IERC721) {
        revert DirectTransferDisabled();
    }

    function setApprovalForAll(address, bool) public pure override(ERC721, IERC721) {
        revert DirectTransferDisabled();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
