// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";

/// @title CorporateRegistration
/// @notice One contract per supervising authority (法務局 by default; 金融庁 etc. for regulated
///         corporations). A soulbound, authority-updatable registration NFT held by the
///         corporation's own (multisig) address; mint and burn write this authority's
///         Corporation flag in the registry (provisional implementation).
/// @dev Spec: docs/state-design/corporations/README.md; ADRs 0005, 0030, 0032 (R1.5, R2.3, R3.5).
///      Officer and beneficial-owner names are public plain text; no addresses are stored.
///      Before burning on dissolution, the authority checks from public data that the
///      corporation has burned its credentials, cancelled its share classes and distributed
///      its assets (R3.5; off-chain check).
contract CorporateRegistration is ERC721, AccessControl {
    bytes32 public constant AUTHORITY_ROLE = keccak256("AUTHORITY_ROLE");

    struct Record {
        string name;
        string registeredOffice;
        string purpose;
        uint256 capital;
        string[] officerNames;
        string[] beneficialOwnerNames; // 25%+ of voting rights, traced through all layers
        bool foreign; // a foreign company's branch in Japan (R2.3)
    }

    IOfficialContractRegistry public immutable registry;
    mapping(uint256 tokenId => Record) private _records;
    mapping(address corporation => uint256 tokenId) public tokenOf;
    uint256 private _nextId = 1;

    event RecordUpdated(uint256 indexed tokenId);

    error Soulbound();
    error AlreadyRegistered();
    error NotRegistered();

    constructor(string memory authorityName, address authority, IOfficialContractRegistry registry_)
        ERC721(authorityName, "CREG")
    {
        registry = registry_;
        _grantRole(DEFAULT_ADMIN_ROLE, authority);
        _grantRole(AUTHORITY_ROLE, authority);
    }

    function mint(address corporation, Record calldata record)
        external
        onlyRole(AUTHORITY_ROLE)
        returns (uint256 tokenId)
    {
        if (tokenOf[corporation] != 0) revert AlreadyRegistered();
        tokenId = _nextId++;
        tokenOf[corporation] = tokenId;
        _records[tokenId] = record;
        _mint(corporation, tokenId);
        registry.register(corporation);
    }

    function updateRecord(address corporation, Record calldata record) external onlyRole(AUTHORITY_ROLE) {
        uint256 tokenId = tokenOf[corporation];
        if (tokenId == 0) revert NotRegistered();
        _records[tokenId] = record;
        emit RecordUpdated(tokenId);
    }

    /// @notice Cessation: dissolution, licence revocation, or the absorbed party in a merger.
    function burn(address corporation) external onlyRole(AUTHORITY_ROLE) {
        uint256 tokenId = tokenOf[corporation];
        if (tokenId == 0) revert NotRegistered();
        delete tokenOf[corporation];
        delete _records[tokenId];
        _burn(tokenId);
        registry.unregister(corporation);
    }

    function recordOf(address corporation) external view returns (Record memory) {
        uint256 tokenId = tokenOf[corporation];
        if (tokenId == 0) revert NotRegistered();
        return _records[tokenId];
    }

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
