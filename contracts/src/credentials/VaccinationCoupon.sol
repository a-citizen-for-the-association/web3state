// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";

interface IResidentLinkOwn {
    function isResident(address account) external view returns (bool);
}

/// @title VaccinationCoupon
/// @notice One contract per municipality and vaccine type (provisional implementation).
///         Issued -> Vaccinated (by a registered vaccinator). A Vaccinated coupon is permanent,
///         except burn on death (R3.10) and re-issue to a successor address, which the
///         municipality may do directly in Vaccinated status (R3.3, follow-up F5).
/// @dev Spec: docs/state-design/credentials/vaccination/README.md; ADRs 0011, 0032 (R3.5: the
///      vaccinator's registration is checked at every `markVaccinated`).
contract VaccinationCoupon is ERC721, AccessControl {
    bytes32 public constant MUNICIPALITY_ROLE = keccak256("MUNICIPALITY_ROLE");
    bytes32 public constant VACCINATOR_ROLE = keccak256("VACCINATOR_ROLE");

    enum Status {
        None,
        Issued,
        Vaccinated
    }

    IOfficialContractRegistry public immutable registry;
    IResidentLinkOwn public immutable ownResidentLink;

    mapping(address holder => uint256 tokenId) public tokenOf;
    mapping(uint256 tokenId => Status) public statusOf;
    uint256 private _nextId = 1;

    event MarkedVaccinated(address indexed holder, address indexed vaccinator);
    event Reissued(address indexed oldHolder, address indexed newHolder, bytes32 migrationRef);

    error Soulbound();
    error NotResident();
    error AlreadyHeld();
    error NotHeld();
    error NotIssued();
    error VaccinatorNotRegistered();
    error CannotBurnVaccinated();
    error SuccessorNotRegistered();

    constructor(string memory name_, address municipality, IOfficialContractRegistry registry_, IResidentLinkOwn link)
        ERC721(name_, "VAXC")
    {
        registry = registry_;
        ownResidentLink = link;
        _grantRole(DEFAULT_ADMIN_ROLE, municipality);
        _grantRole(MUNICIPALITY_ROLE, municipality);
    }

    function mint(address holder) external onlyRole(MUNICIPALITY_ROLE) {
        if (!ownResidentLink.isResident(holder)) revert NotResident();
        _mintTo(holder, Status.Issued);
    }

    function markVaccinated(address holder) external onlyRole(VACCINATOR_ROLE) {
        if (!registry.isRegistered(msg.sender)) revert VaccinatorNotRegistered();
        uint256 tokenId = tokenOf[holder];
        if (statusOf[tokenId] != Status.Issued) revert NotIssued();
        statusOf[tokenId] = Status.Vaccinated;
        emit MarkedVaccinated(holder, msg.sender);
    }

    /// @notice Burn an unused coupon (any reason) or, with `onDeath`, any coupon (R3.10).
    function burn(address holder, bool onDeath) external onlyRole(MUNICIPALITY_ROLE) {
        uint256 tokenId = tokenOf[holder];
        if (tokenId == 0) revert NotHeld();
        if (statusOf[tokenId] == Status.Vaccinated && !onDeath) revert CannotBurnVaccinated();
        _burnFrom(holder);
    }

    /// @notice Re-issue to a successor address in the same status (R3.3, F5).
    function reissue(address oldHolder, address newHolder, bytes32 migrationRef)
        external
        onlyRole(MUNICIPALITY_ROLE)
    {
        if (!registry.isRegistered(newHolder)) revert SuccessorNotRegistered();
        uint256 tokenId = tokenOf[oldHolder];
        if (tokenId == 0) revert NotHeld();
        Status status = statusOf[tokenId];
        _burnFrom(oldHolder);
        _mintTo(newHolder, status);
        emit Reissued(oldHolder, newHolder, migrationRef);
    }

    function statusOfHolder(address holder) external view returns (Status) {
        return statusOf[tokenOf[holder]];
    }

    function _mintTo(address holder, Status status) private {
        if (tokenOf[holder] != 0) revert AlreadyHeld();
        uint256 tokenId = _nextId++;
        tokenOf[holder] = tokenId;
        statusOf[tokenId] = status;
        _mint(holder, tokenId);
    }

    function _burnFrom(address holder) private {
        uint256 tokenId = tokenOf[holder];
        delete tokenOf[holder];
        delete statusOf[tokenId];
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
