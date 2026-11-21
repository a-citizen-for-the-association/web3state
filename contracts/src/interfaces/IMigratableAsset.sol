// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

/// @notice Implemented by every asset-token contract (RealEstateToken, ShareToken) so that the
///         successor-migration contract can move assets on an executed light or heavy path
///         (consistency review R3.2: the heavy path covers every asset token).
interface IMigratableAsset {
    /// @param from The old address.
    /// @param successors Registered successors.
    /// @param sharesBps Each successor's share in basis points (sum = 10_000).
    /// @param data Asset-specific data (e.g. heirs' real-estate agents, R3.9).
    function migrateAll(address from, address[] calldata successors, uint16[] calldata sharesBps, bytes calldata data)
        external;
}
