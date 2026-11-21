// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {IMigratableAsset} from "../interfaces/IMigratableAsset.sol";
import {Kinds} from "./Kinds.sol";

interface IMigratableJPY {
    function balanceOf(address account) external view returns (uint256);
    function migrate(address from, address to, uint256 amount) external;
}

/// @title SuccessorMigration
/// @notice Moves value out of an address whose owner cannot, or must not, sign for it
///         (provisional implementation). It never touches an active, unsuspended address.
///         - Light path: the old address names a new registered address; a registrar holding a
///           kind the old address holds confirms (voluntary change, merger).
///         - Heavy path: a registrar proposes; a court approves (both sign); a public waiting
///           period follows, during which the old address may veto unless it is suspended;
///           then anyone executes. Funds and asset tokens go to registered successors only.
/// @dev Spec: docs/state-design/certified-stablecoin/README.md ("Successor migration");
///      ADRs 0020, 0031, 0032 (R3.1, R3.2, R3.4, R3.9).
///      Simplification: any registrar (other than a factory) may propose the heavy path; the spec
///      says "the registrar of the address's kind", which needs a record of past registrars.
contract SuccessorMigration is AccessControl {
    bytes32 public constant COURT_ROLE = keccak256("COURT_ROLE");

    struct Proposal {
        address oldAddress;
        address proposer;
        uint64 approvedAt;
        bool vetoed;
        bool executed;
        address[] successors;
        uint16[] sharesBps;
        bytes assetData;
    }

    IOfficialContractRegistry public immutable registry;
    IMigratableJPY public immutable jpy;
    uint64 public waitingPeriod;
    address[] public assetContracts;

    mapping(uint256 id => Proposal) private _proposals;
    uint256 public proposalCount;
    /// @notice old address => requested new address (light path).
    mapping(address oldAddress => address newAddress) public lightRequests;

    event AssetContractAdded(address indexed asset);
    event LightRequested(address indexed oldAddress, address indexed newAddress);
    event LightExecuted(address indexed oldAddress, address indexed newAddress, address indexed registrar);
    event HeavyProposed(uint256 indexed id, address indexed oldAddress, address indexed proposer);
    event HeavyApproved(uint256 indexed id, address indexed court);
    event HeavyVetoed(uint256 indexed id);
    event HeavyExecuted(uint256 indexed id);

    error NotRegistrar();
    error AddressIsActive();
    error BadShares();
    error SuccessorNotRegistered(address successor);
    error NoRequest();
    error NotOldAddress();
    error SuspendedCannotVeto();
    error InvalidState();
    error WaitingPeriodNotOver();

    constructor(address admin, IOfficialContractRegistry registry_, IMigratableJPY jpy_, uint64 waitingPeriod_) {
        registry = registry_;
        jpy = jpy_;
        waitingPeriod = waitingPeriod_;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function addAssetContract(address asset) external onlyRole(DEFAULT_ADMIN_ROLE) {
        assetContracts.push(asset);
        emit AssetContractAdded(asset);
    }

    // ---------------- light path ----------------

    function requestLight(address newAddress) external {
        lightRequests[msg.sender] = newAddress;
        emit LightRequested(msg.sender, newAddress);
    }

    function confirmLight(address oldAddress) external {
        address newAddress = lightRequests[oldAddress];
        if (newAddress == address(0)) revert NoRequest();
        if (!registry.isRegistrarOfKind(oldAddress, msg.sender)) revert NotRegistrar();
        delete lightRequests[oldAddress];

        address[] memory successors = new address[](1);
        successors[0] = newAddress;
        uint16[] memory shares = new uint16[](1);
        shares[0] = 10_000;
        _move(oldAddress, successors, shares, "");
        emit LightExecuted(oldAddress, newAddress, msg.sender);
    }

    // ---------------- heavy path ----------------

    function propose(
        address oldAddress,
        address[] calldata successors,
        uint16[] calldata sharesBps,
        bytes calldata assetData
    ) external returns (uint256 id) {
        bytes32 kind = registry.registrarKind(msg.sender);
        if (kind == bytes32(0) || kind == Kinds.FACTORY_DEPLOYED) revert NotRegistrar();
        if (registry.isRegistered(oldAddress) && !registry.isSuspended(oldAddress)) revert AddressIsActive();
        _checkShares(successors, sharesBps);

        id = ++proposalCount;
        Proposal storage p = _proposals[id];
        p.oldAddress = oldAddress;
        p.proposer = msg.sender;
        p.successors = successors;
        p.sharesBps = sharesBps;
        p.assetData = assetData;
        emit HeavyProposed(id, oldAddress, msg.sender);
    }

    /// @notice The court's signature; with the registrar's proposal this is the two-party multisig.
    function approve(uint256 id) external onlyRole(COURT_ROLE) {
        Proposal storage p = _proposals[id];
        if (p.oldAddress == address(0) || p.approvedAt != 0 || p.vetoed) revert InvalidState();
        p.approvedAt = uint64(block.timestamp);
        emit HeavyApproved(id, msg.sender);
    }

    function veto(uint256 id) external {
        Proposal storage p = _proposals[id];
        if (msg.sender != p.oldAddress) revert NotOldAddress();
        if (registry.isSuspended(p.oldAddress)) revert SuspendedCannotVeto();
        if (p.executed) revert InvalidState();
        p.vetoed = true;
        emit HeavyVetoed(id);
    }

    function execute(uint256 id) external {
        Proposal storage p = _proposals[id];
        if (p.approvedAt == 0 || p.vetoed || p.executed) revert InvalidState();
        if (block.timestamp < uint256(p.approvedAt) + waitingPeriod) revert WaitingPeriodNotOver();
        p.executed = true;
        _move(p.oldAddress, p.successors, p.sharesBps, p.assetData);
        emit HeavyExecuted(id);
    }

    function getProposal(uint256 id) external view returns (Proposal memory) {
        return _proposals[id];
    }

    // ---------------- internal ----------------

    function _checkShares(address[] calldata successors, uint16[] calldata sharesBps) private pure {
        if (successors.length == 0 || successors.length != sharesBps.length) revert BadShares();
        uint256 total;
        for (uint256 i; i < sharesBps.length; ++i) {
            total += sharesBps[i];
        }
        if (total != 10_000) revert BadShares();
    }

    function _move(address from, address[] memory successors, uint16[] memory sharesBps, bytes memory assetData)
        private
    {
        for (uint256 i; i < successors.length; ++i) {
            if (!registry.isRegistered(successors[i])) revert SuccessorNotRegistered(successors[i]);
        }
        uint256 balance = jpy.balanceOf(from);
        uint256 distributed;
        for (uint256 i; i < successors.length; ++i) {
            uint256 amount =
                i == successors.length - 1 ? balance - distributed : (balance * sharesBps[i]) / 10_000;
            distributed += amount;
            if (amount > 0) jpy.migrate(from, successors[i], amount);
        }
        for (uint256 i; i < assetContracts.length; ++i) {
            IMigratableAsset(assetContracts[i]).migrateAll(from, successors, sharesBps, assetData);
        }
    }
}
