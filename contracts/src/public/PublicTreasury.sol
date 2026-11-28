// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {IPoliticalFund} from "../interfaces/IPoliticalFund.sol";

/// @title PublicTreasury
/// @notice One per public body per account (provisional implementation). Receives any
///         stablecoin; pays only registered addresses, with a free budget code and a tag.
///         Failed payments in a batch stay owed and can be retried; party grants go through
///         `grant()` so they are accounted income of the PoliticalFund.
/// @dev Spec: docs/state-design/treasury/README.md; ADRs 0019, 0031, 0032 (R1.6, R2.1, R3.8, R5.7).
///      Budget codes are not validated on-chain; no code may correspond to a single named person.
contract PublicTreasury {
    using SafeERC20 for IERC20;

    enum Tag {
        Normal,
        OffChainExit
    }

    uint8 private constant PUBLIC_GRANT = 4;

    IOfficialContractRegistry public immutable registry;
    IERC20 public immutable jpy;
    address public immutable controller; // the accounting officer's multisig

    /// @notice Amounts owed after a failed batch payment, by payee and budget code.
    mapping(address payee => mapping(bytes32 budgetCode => uint256)) public owed;

    event Paid(address indexed to, uint256 amount, bytes32 indexed budgetCode, Tag tag);
    event PaymentFailed(address indexed to, uint256 amount, bytes32 indexed budgetCode);

    error NotController();
    error PayeeNotRegistered(address to);
    error NothingOwed();
    error LengthMismatch();

    constructor(IOfficialContractRegistry registry_, IERC20 jpy_, address controller_) {
        registry = registry_;
        jpy = jpy_;
        controller = controller_;
    }

    modifier onlyController() {
        if (msg.sender != controller) revert NotController();
        _;
    }

    function pay(address to, uint256 amount, bytes32 budgetCode, Tag tag) external onlyController {
        _pay(to, amount, budgetCode, tag);
    }

    /// @notice Pays many payees; each failure is recorded as owed instead of failing the batch.
    function payMany(address[] calldata to, uint256[] calldata amounts, bytes32 budgetCode) external onlyController {
        if (to.length != amounts.length) revert LengthMismatch();
        for (uint256 i; i < to.length; ++i) {
            try this.payOne(to[i], amounts[i], budgetCode) {}
            catch {
                owed[to[i]][budgetCode] += amounts[i];
                emit PaymentFailed(to[i], amounts[i], budgetCode);
            }
        }
    }

    /// @dev External so that `payMany` can isolate failures with try/catch; self-call only.
    function payOne(address to, uint256 amount, bytes32 budgetCode) external {
        if (msg.sender != address(this)) revert NotController();
        _pay(to, amount, budgetCode, Tag.Normal);
    }

    function retry(address to, bytes32 budgetCode) external onlyController {
        uint256 amount = owed[to][budgetCode];
        if (amount == 0) revert NothingOwed();
        owed[to][budgetCode] = 0;
        _pay(to, amount, budgetCode, Tag.Normal);
    }

    /// @notice Pays a party grant into a PoliticalFund as accounted `PublicGrant` income.
    function grant(IPoliticalFund fund, uint256 amount, bytes32 budgetCode) external onlyController {
        jpy.forceApprove(address(fund), amount);
        fund.contribute(amount, PUBLIC_GRANT, address(0));
        emit Paid(address(fund), amount, budgetCode, Tag.Normal);
    }

    function _pay(address to, uint256 amount, bytes32 budgetCode, Tag tag) private {
        if (!registry.isRegistered(to)) revert PayeeNotRegistered(to);
        jpy.safeTransfer(to, amount);
        emit Paid(to, amount, budgetCode, tag);
    }
}
