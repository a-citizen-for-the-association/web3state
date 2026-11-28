// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";

/// @title CorporateMultisig
/// @notice A minimal M-of-N multisig used as a corporation's (or a public body's) address,
///         signed with the officers' own registered addresses (provisional implementation; the
///         audited production standard, e.g. Safe, is a backlog item).
///         - Only signers that are registered and not suspended count (R3.6).
///         - The multisig rotates its own signers by calling itself.
///         - If the threshold cannot be met, the registrar replaces the signers after a public
///           waiting period; any counting signer may object, which sends it to a court.
/// @dev Spec: docs/state-design/corporations/README.md ("Signer rotation"); ADRs 0005, 0032 (R3.6).
///      Simplification: confirmations are a bitmap over signer indices, so changing the signer
///      set leaves pending transactions with stale confirmations; resubmit them after a change.
contract CorporateMultisig {
    bytes32 public constant COURT_ROLE = keccak256("COURT_ROLE");

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations; // bitmap over signer indices
    }

    struct Replacement {
        address[] signers;
        uint256 threshold;
        uint64 proposedAt;
        bool objected;
        bool courtApproved;
        bool done;
    }

    IOfficialContractRegistry public immutable registry;
    address public immutable registrar;
    uint64 public immutable replacementWaitingPeriod;

    address[] private _signers;
    uint256 public threshold;
    Transaction[] private _txs;
    Replacement[] private _replacements;

    event Submitted(uint256 indexed txId, address indexed signer, address to, uint256 value);
    event Confirmed(uint256 indexed txId, address indexed signer);
    event Executed(uint256 indexed txId);
    event SignersChanged(address[] signers, uint256 threshold);
    event ReplacementProposed(uint256 indexed id);
    event ReplacementObjected(uint256 indexed id, address indexed signer);
    event ReplacementCourtApproved(uint256 indexed id);

    error NotSigner();
    error NotSelf();
    error NotRegistrar();
    error NotCourt();
    error BadThreshold();
    error AlreadyExecuted();
    error NotEnoughConfirmations(uint256 counted, uint256 needed);
    error CallFailed();
    error ReplacementBlocked();
    error WaitingPeriodNotOver();

    constructor(
        address[] memory signers_,
        uint256 threshold_,
        IOfficialContractRegistry registry_,
        address registrar_,
        uint64 replacementWaitingPeriod_
    ) {
        registry = registry_;
        registrar = registrar_;
        replacementWaitingPeriod = replacementWaitingPeriod_;
        _setSigners(signers_, threshold_);
    }

    receive() external payable {}

    // ---------------- transactions ----------------

    function submit(address to, uint256 value, bytes calldata data) external returns (uint256 txId) {
        uint256 index = _signerIndex(msg.sender);
        txId = _txs.length;
        _txs.push(Transaction({to: to, value: value, data: data, executed: false, confirmations: 1 << index}));
        emit Submitted(txId, msg.sender, to, value);
        emit Confirmed(txId, msg.sender);
    }

    function confirm(uint256 txId) external {
        uint256 index = _signerIndex(msg.sender);
        _txs[txId].confirmations |= 1 << index;
        emit Confirmed(txId, msg.sender);
    }

    function execute(uint256 txId) external {
        Transaction storage t = _txs[txId];
        if (t.executed) revert AlreadyExecuted();
        uint256 counted = countValidConfirmations(txId);
        if (counted < threshold) revert NotEnoughConfirmations(counted, threshold);
        t.executed = true;
        (bool ok,) = t.to.call{value: t.value}(t.data);
        if (!ok) revert CallFailed();
        emit Executed(txId);
    }

    /// @notice Confirmations from signers that are registered and not suspended right now.
    function countValidConfirmations(uint256 txId) public view returns (uint256 counted) {
        uint256 bitmap = _txs[txId].confirmations;
        for (uint256 i; i < _signers.length; ++i) {
            if (bitmap & (1 << i) != 0 && _counts(_signers[i])) counted++;
        }
    }

    // ---------------- rotation by the multisig itself ----------------

    function setSigners(address[] calldata signers_, uint256 threshold_) external {
        if (msg.sender != address(this)) revert NotSelf();
        _setSigners(signers_, threshold_);
    }

    // ---------------- replacement by the registrar ----------------

    function proposeReplacement(address[] calldata signers_, uint256 threshold_) external returns (uint256 id) {
        if (msg.sender != registrar) revert NotRegistrar();
        id = _replacements.length;
        Replacement storage r = _replacements.push();
        r.signers = signers_;
        r.threshold = threshold_;
        r.proposedAt = uint64(block.timestamp);
        emit ReplacementProposed(id);
    }

    function objectToReplacement(uint256 id) external {
        uint256 index = _signerIndex(msg.sender);
        if (!_counts(_signers[index])) revert NotSigner();
        _replacements[id].objected = true;
        emit ReplacementObjected(id, msg.sender);
    }

    function courtApproveReplacement(uint256 id) external {
        if (!IAccessControl(address(registry)).hasRole(COURT_ROLE, msg.sender)) revert NotCourt();
        _replacements[id].courtApproved = true;
        emit ReplacementCourtApproved(id);
    }

    function executeReplacement(uint256 id) external {
        Replacement storage r = _replacements[id];
        if (r.done) revert AlreadyExecuted();
        if (r.objected && !r.courtApproved) revert ReplacementBlocked();
        if (block.timestamp < uint256(r.proposedAt) + replacementWaitingPeriod) revert WaitingPeriodNotOver();
        r.done = true;
        _setSigners(r.signers, r.threshold);
    }

    // ---------------- views ----------------

    function signers() external view returns (address[] memory) {
        return _signers;
    }

    // ---------------- internal ----------------

    function _counts(address signer) private view returns (bool) {
        return registry.isRegistered(signer) && !registry.isSuspended(signer);
    }

    function _signerIndex(address account) private view returns (uint256) {
        for (uint256 i; i < _signers.length; ++i) {
            if (_signers[i] == account) return i;
        }
        revert NotSigner();
    }

    function _setSigners(address[] memory signers_, uint256 threshold_) private {
        if (threshold_ == 0 || threshold_ > signers_.length || signers_.length > 256) revert BadThreshold();
        _signers = signers_;
        threshold = threshold_;
        emit SignersChanged(signers_, threshold_);
    }
}
