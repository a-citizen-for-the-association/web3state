// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";

/// @title ResidentLink
/// @notice One contract per municipality. A soulbound token proving only "this address is linked
///         to a resident of this municipality" (provisional implementation).
///         Mint and burn also write this municipality's Resident flag in the registry.
/// @dev Spec: docs/state-design/citizenship/README.md; ADRs 0003, 0031, 0032 (R1.5, R3.8).
///      On a domestic move the new municipality mints first and the old one burns afterwards,
///      so the address is never unregistered.
contract ResidentLink is ERC721, AccessControl {
    bytes32 public constant MUNICIPALITY_ROLE = keccak256("MUNICIPALITY_ROLE");

    IOfficialContractRegistry public immutable registry;

    /// @notice Set at mint and never cleared (proof of past residence).
    mapping(address account => bool) public everIssued;
    mapping(address account => uint256 tokenId) public tokenOf;
    uint256 private _nextId = 1;

    error Soulbound();
    error AlreadyResident();
    error NotResident();

    constructor(string memory name_, address municipality, IOfficialContractRegistry registry_)
        ERC721(name_, "RLINK")
    {
        registry = registry_;
        _grantRole(DEFAULT_ADMIN_ROLE, municipality);
        _grantRole(MUNICIPALITY_ROLE, municipality);
    }

    function mint(address resident) external onlyRole(MUNICIPALITY_ROLE) returns (uint256 tokenId) {
        if (tokenOf[resident] != 0) revert AlreadyResident();
        tokenId = _nextId++;
        tokenOf[resident] = tokenId;
        everIssued[resident] = true;
        _mint(resident, tokenId);
        registry.register(resident);
    }

    /// @notice Revocation (move-out after the new municipality has minted, death, correction).
    ///         The reason is never recorded on-chain.
    function burn(address resident) external onlyRole(MUNICIPALITY_ROLE) {
        uint256 tokenId = tokenOf[resident];
        if (tokenId == 0) revert NotResident();
        delete tokenOf[resident];
        _burn(tokenId);
        registry.unregister(resident);
    }

    function isResident(address account) external view returns (bool) {
        return tokenOf[account] != 0;
    }

    /// @dev Only mint (from == 0) and burn (to == 0) are allowed: the token is soulbound.
    function _update(address to, uint256 tokenId, address auth) internal override returns (address from) {
        from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) revert Soulbound();
        return super._update(to, tokenId, auth);
    }

    function approve(address, uint256) public pure override {
        revert Soulbound();
    }

    function setApprovalForAll(address, bool) public pure override {
        revert Soulbound();
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
