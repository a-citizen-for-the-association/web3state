// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {IPoliticalFund} from "../interfaces/IPoliticalFund.sol";
import {Kinds} from "../core/Kinds.sol";

interface IPoliticalFundFactory {
    function cap(bytes32 donorKind, uint8 orgType, uint8 category) external view returns (uint256);
    function isActive(address fund) external view returns (bool);
}

/// @title PoliticalFund
/// @notice One per political organization, deployed by `PoliticalFundFactory` (provisional
///         implementation). `contribute` is the only accounted way in; unaccounted transfers
///         cannot be spent and can only be forfeited to the treasury.
/// @dev Spec: docs/state-design/political-donations/README.md; ADRs 0015, 0032 (R2.1).
///      Donor identity: the identity contract must be an official ResidentLink or
///      CorporateRegistration contract, and the donor must hold its token. Corporations may give
///      only to parties. Caps per donor kind × organization type × category and calendar year
///      (JST). `PublicGrant` comes only from a PublicTreasury contract, without a cap.
contract PoliticalFund is IPoliticalFund {
    using SafeERC20 for IERC20;

    uint8 public constant DONATION = 0;
    uint8 public constant PUBLIC_GRANT = 4;
    uint8 public constant ORG_PARTY = 0;

    IOfficialContractRegistry public immutable registry;
    IPoliticalFundFactory public immutable factory;
    IERC20 public immutable jpy;
    address public immutable controller;
    address public immutable treasury;
    uint8 public immutable orgType; // 0 Party, 1 FundRaisingBody, 2 FundManagementBody, 3 Other

    uint256 public accountedBalance;
    mapping(address donor => mapping(uint256 year => mapping(uint8 category => uint256))) public given;

    event Contribution(address indexed donor, address identityContract, uint8 category, uint256 amount, uint256 year);
    event Spent(address indexed to, uint256 amount, bytes32 purpose);
    event Forfeited(uint256 amount);

    error Inactive();
    error NotOfficialIdentity();
    error NotHolder();
    error CorporationsOnlyToParties();
    error CapExceeded();
    error NotTreasury();
    error NotController();
    error ExceedsAccounted();

    constructor(
        IOfficialContractRegistry registry_,
        IERC20 jpy_,
        address controller_,
        address treasury_,
        uint8 orgType_
    ) {
        registry = registry_;
        factory = IPoliticalFundFactory(msg.sender);
        jpy = jpy_;
        controller = controller_;
        treasury = treasury_;
        orgType = orgType_;
    }

    function contribute(uint256 amount, uint8 category, address identityContract) external {
        if (!factory.isActive(address(this))) revert Inactive();
        if (category == PUBLIC_GRANT) {
            if (registry.kindOf(msg.sender) != Kinds.PUBLIC_TREASURY_CONTRACT) revert NotTreasury();
        } else {
            bytes32 kind = registry.kindOf(identityContract);
            if (kind != Kinds.RESIDENT_LINK_CONTRACT && kind != Kinds.CORPORATE_REGISTRATION_CONTRACT) {
                revert NotOfficialIdentity();
            }
            if (IERC721(identityContract).balanceOf(msg.sender) == 0) revert NotHolder();
            if (kind == Kinds.CORPORATE_REGISTRATION_CONTRACT && orgType != ORG_PARTY) {
                revert CorporationsOnlyToParties();
            }
            uint256 year = jstYear(block.timestamp);
            uint256 total = given[msg.sender][year][category] + amount;
            if (total > factory.cap(kind, orgType, category)) revert CapExceeded();
            given[msg.sender][year][category] = total;
        }
        jpy.safeTransferFrom(msg.sender, address(this), amount);
        accountedBalance += amount;
        emit Contribution(msg.sender, identityContract, category, amount, jstYear(block.timestamp));
    }

    function spend(address to, uint256 amount, bytes32 purpose) external {
        if (msg.sender != controller) revert NotController();
        if (amount > accountedBalance) revert ExceedsAccounted();
        accountedBalance -= amount;
        jpy.safeTransfer(to, amount);
        emit Spent(to, amount, purpose);
    }

    function forfeitUnaccounted() external {
        uint256 extra = jpy.balanceOf(address(this)) - accountedBalance;
        jpy.safeTransfer(treasury, extra);
        emit Forfeited(extra);
    }

    /// @notice Gregorian calendar year in Japan Standard Time (UTC+9).
    function jstYear(uint256 timestamp) public pure returns (uint256) {
        // Days-to-civil (H. Hinnant), for dates after 1970.
        uint256 z = (timestamp + 9 hours) / 1 days + 719_468;
        uint256 era = z / 146_097;
        uint256 doe = z - era * 146_097;
        uint256 yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
        uint256 y = yoe + era * 400;
        uint256 doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        uint256 mp = (5 * doy + 2) / 153;
        uint256 m = mp < 10 ? mp + 3 : mp - 9;
        return m <= 2 ? y + 1 : y;
    }
}

/// @title PoliticalFundFactory
/// @notice One per election board. Deploys funds, registers each in the registry (it is an
///         approved factory registrar), and keeps the legal caps and the active flag (the
///         registration NFT's existence, simplified to a flag the board clears on dissolution).
contract PoliticalFundFactory is IPoliticalFundFactory {
    IOfficialContractRegistry public immutable registry;
    IERC20 public immutable jpy;
    address public immutable board;
    address public immutable treasury;

    mapping(bytes32 donorKind => mapping(uint8 orgType => mapping(uint8 category => uint256))) public cap;
    mapping(address fund => bool) public isActive;

    event FundCreated(address indexed fund, uint8 orgType, address controller);
    event FundDissolved(address indexed fund);

    error NotBoard();

    constructor(IOfficialContractRegistry registry_, IERC20 jpy_, address board_, address treasury_) {
        registry = registry_;
        jpy = jpy_;
        board = board_;
        treasury = treasury_;
    }

    modifier onlyBoard() {
        if (msg.sender != board) revert NotBoard();
        _;
    }

    function setCap(bytes32 donorKind, uint8 orgType, uint8 category, uint256 amount) external onlyBoard {
        cap[donorKind][orgType][category] = amount;
    }

    function createFund(address controller, uint8 orgType) external onlyBoard returns (PoliticalFund fund) {
        fund = new PoliticalFund(registry, jpy, controller, treasury, orgType);
        isActive[address(fund)] = true;
        registry.register(address(fund));
        emit FundCreated(address(fund), orgType, controller);
    }

    /// @notice Dissolution: the fund stops accepting contributions and loses its registration.
    function dissolve(address fund) external onlyBoard {
        isActive[fund] = false;
        registry.unregister(fund);
        emit FundDissolved(fund);
    }
}
