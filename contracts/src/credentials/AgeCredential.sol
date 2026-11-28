// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {Kinds} from "../core/Kinds.sol";

/// @title AgeCredential
/// @notice One contract per municipality; each age threshold (18, 20, ...) is a token type
///         (provisional implementation). Soulbound, possession-only, no birth date on-chain.
///         Minted monthly in a batch (or earlier on request); never burned on a move; burned on
///         death; re-issued to a successor address.
/// @dev Spec: docs/state-design/personal-data/README.md; ADRs 0028, 0032 (R3.3, R3.10, R4.3, R5.5).
///      A verifier checks `isOfAge`: the age token plus a Resident or NationalAbroad registration
///      at the same address.
contract AgeCredential is ERC1155, AccessControl {
    bytes32 public constant MUNICIPALITY_ROLE = keccak256("MUNICIPALITY_ROLE");

    IOfficialContractRegistry public immutable registry;

    event Reissued(address indexed oldHolder, address indexed newHolder, bytes32 migrationRef);

    error Soulbound();
    error SuccessorNotRegistered();

    constructor(address municipality, IOfficialContractRegistry registry_) ERC1155("") {
        registry = registry_;
        _grantRole(DEFAULT_ADMIN_ROLE, municipality);
        _grantRole(MUNICIPALITY_ROLE, municipality);
    }

    /// @notice The monthly batch: everyone who reached `threshold` in the previous month.
    function mintBatch(address[] calldata holders, uint256 threshold) external onlyRole(MUNICIPALITY_ROLE) {
        for (uint256 i; i < holders.length; ++i) {
            if (balanceOf(holders[i], threshold) == 0) _mint(holders[i], threshold, 1, "");
        }
    }

    function burnOnDeath(address holder, uint256[] calldata thresholds) external onlyRole(MUNICIPALITY_ROLE) {
        for (uint256 i; i < thresholds.length; ++i) {
            if (balanceOf(holder, thresholds[i]) != 0) _burn(holder, thresholds[i], 1);
        }
    }

    function reissue(address oldHolder, address newHolder, uint256[] calldata thresholds, bytes32 migrationRef)
        external
        onlyRole(MUNICIPALITY_ROLE)
    {
        if (!registry.isRegistered(newHolder)) revert SuccessorNotRegistered();
        for (uint256 i; i < thresholds.length; ++i) {
            if (balanceOf(oldHolder, thresholds[i]) != 0) {
                _burn(oldHolder, thresholds[i], 1);
                _mint(newHolder, thresholds[i], 1, "");
            }
        }
        emit Reissued(oldHolder, newHolder, migrationRef);
    }

    function isOfAge(address holder, uint256 threshold) external view returns (bool) {
        bool registeredPerson =
            registry.isRegisteredAs(holder, Kinds.RESIDENT) || registry.isRegisteredAs(holder, Kinds.NATIONAL_ABROAD);
        return registeredPerson && balanceOf(holder, threshold) != 0;
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override {
        if (from != address(0) && to != address(0)) revert Soulbound();
        super._update(from, to, ids, values);
    }

    function setApprovalForAll(address, bool) public pure override {
        revert Soulbound();
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
