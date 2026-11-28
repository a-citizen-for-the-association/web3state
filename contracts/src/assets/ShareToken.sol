// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {IMigratableAsset} from "../interfaces/IMigratableAsset.sol";
import {Kinds} from "../core/Kinds.sol";

/// @title ShareToken
/// @notice One contract run by the Legal Affairs Bureau (provisional implementation). One token
///         id per corporation and share class (and per vehicle, for units); balances only at
///         eligible registered addresses, so ownership can be followed to the final individual.
///         - Issuance and cancellation only by the corporation's own address, citing the
///           resolution hash anchored in AnchorRegistry (CorporateResolution).
///         - Transfer-restricted classes need the corporation's approval for each transfer.
///         - Operator approvals (brokers, the clearing contract) lapse while the holder is
///           unregistered or suspended; such holders cannot transfer, and their shares move only
///           by the successor-migration contract (R3.2).
/// @dev Spec: docs/state-design/securities/README.md; ADRs 0030, 0032 (R1.3, R3.2, R4.3).
///      Optional agents for shares (spec) are not implemented in this provisional version.
contract ShareToken is ERC1155, AccessControl, IMigratableAsset {
    bytes32 public constant BUREAU_ROLE = keccak256("BUREAU_ROLE");
    bytes32 public constant MIGRATOR_ROLE = keccak256("MIGRATOR_ROLE");

    struct ShareClass {
        address corporation;
        bool transferRestricted;
    }

    IOfficialContractRegistry public immutable registry;
    mapping(uint256 classId => ShareClass) public classes;
    uint256 public classCount;
    /// @notice One-time approvals for transfer-restricted classes: class => from => to => amount.
    mapping(uint256 classId => mapping(address from => mapping(address to => uint256))) public restrictedApproval;
    mapping(address holder => uint256[]) private _classesHeld;
    mapping(address holder => mapping(uint256 classId => bool)) private _tracked;

    event ClassCreated(uint256 indexed classId, address indexed corporation, bool transferRestricted);
    event Issued(uint256 indexed classId, address indexed to, uint256 amount, bytes32 resolutionHash);
    event Cancelled(uint256 indexed classId, address indexed from, uint256 amount, bytes32 resolutionHash);

    error NotCorporation();
    error NotEligibleHolder(address account);
    error HolderInactive(address account);
    error RestrictedTransferNotApproved();

    constructor(address bureau, IOfficialContractRegistry registry_) ERC1155("") {
        registry = registry_;
        _grantRole(DEFAULT_ADMIN_ROLE, bureau);
        _grantRole(BUREAU_ROLE, bureau);
    }

    function createClass(address corporation, bool transferRestricted)
        external
        onlyRole(BUREAU_ROLE)
        returns (uint256 classId)
    {
        classId = ++classCount;
        classes[classId] = ShareClass(corporation, transferRestricted);
        emit ClassCreated(classId, corporation, transferRestricted);
    }

    function issue(uint256 classId, address to, uint256 amount, bytes32 resolutionHash) external {
        if (msg.sender != classes[classId].corporation) revert NotCorporation();
        _mint(to, classId, amount, "");
        emit Issued(classId, to, amount, resolutionHash);
    }

    /// @notice Buybacks, mergers, and cancellation of all classes before dissolution (R3.5).
    function cancel(uint256 classId, address from, uint256 amount, bytes32 resolutionHash) external {
        if (msg.sender != classes[classId].corporation) revert NotCorporation();
        _burn(from, classId, amount);
        emit Cancelled(classId, from, amount, resolutionHash);
    }

    function approveRestrictedTransfer(uint256 classId, address from, address to, uint256 amount) external {
        if (msg.sender != classes[classId].corporation) revert NotCorporation();
        restrictedApproval[classId][from][to] = amount;
    }

    /// @notice Operator approvals lapse while the holder is unregistered or suspended (R3.2).
    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        if (!_active(account)) return false;
        return super.isApprovedForAll(account, operator);
    }

    /// @inheritdoc IMigratableAsset
    function migrateAll(address from, address[] calldata successors, uint16[] calldata sharesBps, bytes calldata)
        external
        onlyRole(MIGRATOR_ROLE)
    {
        uint256[] memory held = _classesHeld[from];
        for (uint256 c; c < held.length; ++c) {
            uint256 classId = held[c];
            uint256 balance = balanceOf(from, classId);
            if (balance == 0) continue;
            uint256 moved;
            for (uint256 i; i < successors.length; ++i) {
                uint256 amount = i == successors.length - 1 ? balance - moved : (balance * sharesBps[i]) / 10_000;
                moved += amount;
                if (amount > 0) _moveRaw(from, successors[i], classId, amount);
            }
        }
    }

    function classesHeld(address holder) external view returns (uint256[] memory) {
        return _classesHeld[holder];
    }

    // ---------------- internal ----------------

    bool private _rawMove;

    function _moveRaw(address from, address to, uint256 classId, uint256 amount) private {
        _rawMove = true;
        _safeTransferFrom(from, to, classId, amount, "");
        _rawMove = false;
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override {
        if (to != address(0)) _requireEligible(to);
        if (from != address(0) && to != address(0) && !_rawMove) {
            if (!_active(from)) revert HolderInactive(from);
            for (uint256 i; i < ids.length; ++i) {
                if (classes[ids[i]].transferRestricted) {
                    uint256 allowed = restrictedApproval[ids[i]][from][to];
                    if (allowed < values[i]) revert RestrictedTransferNotApproved();
                    restrictedApproval[ids[i]][from][to] = allowed - values[i];
                }
            }
        }
        super._update(from, to, ids, values);
        if (to != address(0)) {
            for (uint256 i; i < ids.length; ++i) {
                if (!_tracked[to][ids[i]]) {
                    _tracked[to][ids[i]] = true;
                    _classesHeld[to].push(ids[i]);
                }
            }
        }
    }

    function _active(address account) private view returns (bool) {
        return registry.isRegistered(account) && !registry.isSuspended(account);
    }

    function _requireEligible(address account) private view {
        bool ok = registry.isRegisteredAs(account, Kinds.RESIDENT) || registry.isRegisteredAs(account, Kinds.NATIONAL_ABROAD)
            || registry.isRegisteredAs(account, Kinds.CORPORATION) || registry.isRegisteredAs(account, Kinds.PUBLIC_CONTRACT)
            || registry.isRegisteredAs(account, Kinds.FOREIGN_INVESTOR)
            || registry.isRegisteredAs(account, Kinds.FINANCIAL_VEHICLE);
        if (!ok) revert NotEligibleHolder(account);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
