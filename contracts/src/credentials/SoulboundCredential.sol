// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {Kinds} from "../core/Kinds.sol";

interface IResidentLinkView {
    function isResident(address account) external view returns (bool);
}

/// @title SoulboundCredential
/// @notice Generic possession-only credential, one contract per issuer (provisional
///         implementation). Used for Passport (外務省), Diploma (each school), License
///         (公安委員会), HealthInsurance (each insurer) and EmployeeID (each company).
///         - `requiresResident`: at mint, the recipient must hold a valid ResidentLink from a
///           contract the applicant declares, which the registry must list as a genuine
///           ResidentLink contract (diploma, license, health insurance).
///         - Credentials-wide rules: re-issue to a successor address after a recorded succession
///           (R3.3) and burn on death (R3.10). Reasons are never recorded on-chain.
/// @dev Specs: docs/state-design/credentials/*/README.md; ADRs 0006–0010, 0032.
contract SoulboundCredential is ERC721, AccessControl {
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    IOfficialContractRegistry public immutable registry;
    bool public immutable requiresResident;

    mapping(address holder => uint256 tokenId) public tokenOf;
    uint256 private _nextId = 1;

    event Reissued(address indexed oldHolder, address indexed newHolder, bytes32 migrationRef);

    error Soulbound();
    error AlreadyHeld();
    error NotHeld();
    error NotAResidentLinkContract();
    error NotResident();
    error SuccessorNotRegistered();

    constructor(
        string memory name_,
        string memory symbol_,
        address issuer,
        IOfficialContractRegistry registry_,
        bool requiresResident_
    ) ERC721(name_, symbol_) {
        registry = registry_;
        requiresResident = requiresResident_;
        _grantRole(DEFAULT_ADMIN_ROLE, issuer);
        _grantRole(ISSUER_ROLE, issuer);
    }

    /// @param declaredResidentLink The ResidentLink contract the applicant declares (ignored
    ///        when `requiresResident` is false).
    function mint(address holder, address declaredResidentLink) external onlyRole(ISSUER_ROLE) returns (uint256) {
        if (requiresResident) _checkResident(holder, declaredResidentLink);
        return _mintTo(holder);
    }

    /// @notice Burn: revocation, disenrolment, end of employment, renewal, or death (R3.10).
    function burn(address holder) external onlyRole(ISSUER_ROLE) {
        _burnFrom(holder);
    }

    /// @notice Re-issue after a recorded succession (R3.3). `migrationRef` identifies the on-chain
    ///         succession record (light or heavy path) that the issuer checked.
    function reissue(address oldHolder, address newHolder, bytes32 migrationRef) external onlyRole(ISSUER_ROLE) {
        if (!registry.isRegistered(newHolder)) revert SuccessorNotRegistered();
        _burnFrom(oldHolder);
        _mintTo(newHolder);
        emit Reissued(oldHolder, newHolder, migrationRef);
    }

    function holds(address account) external view returns (bool) {
        return tokenOf[account] != 0;
    }

    function _checkResident(address holder, address declared) internal view {
        if (registry.kindOf(declared) != Kinds.RESIDENT_LINK_CONTRACT) revert NotAResidentLinkContract();
        if (!IResidentLinkView(declared).isResident(holder)) revert NotResident();
    }

    function _mintTo(address holder) private returns (uint256 tokenId) {
        if (tokenOf[holder] != 0) revert AlreadyHeld();
        tokenId = _nextId++;
        tokenOf[holder] = tokenId;
        _mint(holder, tokenId);
    }

    function _burnFrom(address holder) private {
        uint256 tokenId = tokenOf[holder];
        if (tokenId == 0) revert NotHeld();
        delete tokenOf[holder];
        _burn(tokenId);
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
