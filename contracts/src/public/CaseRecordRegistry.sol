// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

/// @title CaseRecordRegistry
/// @notice One per court (provisional implementation). Registers case records (including
///         judgments) with a retention class. Disposal must be registered, and is rejected for
///         special-preservation and permanent records unless the class is first lowered in a
///         public event. Stored state is needed for that check, so this registry was not folded
///         into AnchorRegistry (R4.1).
/// @dev Spec: docs/state-design/judiciary/README.md; ADRs 0018, 0032.
contract CaseRecordRegistry {
    enum RetentionClass {
        Standard,
        SpecialPreservation,
        Permanent
    }

    struct CaseRecord {
        bytes32 caseRef;
        bytes32 recordType; // e.g. keccak256("Judgment")
        bytes32 recordHash;
        RetentionClass retentionClass;
        uint256 previousId; // 0 = none
        bool disposed;
    }

    address public immutable court;
    CaseRecord[] private _records; // id = index + 1

    event RecordRegistered(uint256 indexed id, bytes32 indexed caseRef, bytes32 recordType, bytes32 recordHash);
    event Reclassified(uint256 indexed id, RetentionClass from, RetentionClass to);
    event Disposed(uint256 indexed id);

    error NotCourt();
    error UnknownRecord();
    error ProtectedRecord();
    error AlreadyDisposed();

    constructor(address court_) {
        court = court_;
    }

    modifier onlyCourt() {
        if (msg.sender != court) revert NotCourt();
        _;
    }

    function register(
        bytes32 caseRef,
        bytes32 recordType,
        bytes32 recordHash,
        RetentionClass retentionClass,
        uint256 previousId
    ) external onlyCourt returns (uint256 id) {
        _records.push(CaseRecord(caseRef, recordType, recordHash, retentionClass, previousId, false));
        id = _records.length;
        emit RecordRegistered(id, caseRef, recordType, recordHash);
    }

    function reclassify(uint256 id, RetentionClass newClass) external onlyCourt {
        CaseRecord storage r = _get(id);
        emit Reclassified(id, r.retentionClass, newClass);
        r.retentionClass = newClass;
    }

    function dispose(uint256 id) external onlyCourt {
        CaseRecord storage r = _get(id);
        if (r.disposed) revert AlreadyDisposed();
        if (r.retentionClass != RetentionClass.Standard) revert ProtectedRecord();
        r.disposed = true;
        emit Disposed(id);
    }

    function recordOf(uint256 id) external view returns (CaseRecord memory) {
        return _get(id);
    }

    function _get(uint256 id) private view returns (CaseRecord storage) {
        if (id == 0 || id > _records.length) revert UnknownRecord();
        return _records[id - 1];
    }
}
