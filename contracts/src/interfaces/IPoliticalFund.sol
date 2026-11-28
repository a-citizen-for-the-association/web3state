// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

/// @notice The accounted entry point of a PoliticalFund (ADR 0015), as called by treasuries.
interface IPoliticalFund {
    /// @dev Categories: 0 Donation, 1 PartyTicket, 2 MembershipFee, 3 Other, 4 PublicGrant.
    function contribute(uint256 amount, uint8 category, address identityContract) external;
}
