// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";

/// @title AnchorRegistry
/// @notice One shared, event-only contract for hash anchors (provisional implementation).
///         Any registered address may anchor; the author of a document anchors it. The contract
///         does not restrict kinds: obligations are law, checked afterwards. Nothing is stored.
///         Kinds include ApprovalDocument, Evidence, AccessLog, RealEstateRight,
///         CorporateResolution, TradeReport, ExpenseReport, LeavingStatement.
/// @dev Spec: docs/state-design/certified-stablecoin/README.md ("AnchorRegistry kinds");
///      ADRs 0017, 0018, 0028, 0032 (R1.4, R4.1, R4.2).
///      `previousId` links a correction or status change to an earlier anchor; this implementation
///      uses the earlier anchor's hash as its identifier.
contract AnchorRegistry {
    IOfficialContractRegistry public immutable registry;

    event Anchored(address indexed caller, bytes32 indexed hash, bytes32 indexed kind, bytes32 previousId, bytes data);

    error CallerNotRegistered();

    constructor(IOfficialContractRegistry registry_) {
        registry = registry_;
    }

    function anchor(bytes32 hash, bytes32 kind, bytes32 previousId, bytes calldata data) external {
        if (!registry.isRegistered(msg.sender)) revert CallerNotRegistered();
        emit Anchored(msg.sender, hash, kind, previousId, data);
    }
}
