// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

/// @notice The part of OfficialContractRegistry that other contracts call.
interface IOfficialContractRegistry {
    function kindOf(address contractAddress) external view returns (bytes32);
    function registrarKind(address registrar) external view returns (bytes32);
    function hasFlag(address account, address registrar) external view returns (bool);
    function isRegistered(address account) external view returns (bool);
    function isRegistrarOfKind(address account, address registrar) external view returns (bool);
    function isRegisteredAs(address account, bytes32 kind) external view returns (bool);
    function isVip(address account) external view returns (bool);
    function isExempt(address account) external view returns (bool);
    function isSuspended(address account) external view returns (bool);
    function unregisteredCap() external view returns (uint256);
    function capPeriod() external view returns (uint64);
    function register(address account) external;
    function unregister(address account) external;
}
