// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

/// @title ClearingContract
/// @notice Daily net settlement of listed shares, run by the clearing house (provisional
///         implementation). Net sellers' shares and net buyers' money are collected, then
///         delivered; each delivery fails on its own and stays here for a retry (R3.8), so one
///         failing holder never fails the whole batch.
///         Collection uses the holders' approvals to this contract (shares: operator approval;
///         money: allowance), which lapse for unregistered or suspended holders (R3.2).
/// @dev Spec: docs/state-design/securities/README.md ("Listed shares"); ADRs 0030, 0032.
///      Registered by the FSA as a FinancialVehicle. Exchanges' and brokers' daily execution
///      roots are anchored in AnchorRegistry (kind TradeReport); no extra code is needed here.
contract ClearingContract is ERC1155Holder {
    struct ShareMove {
        address from;
        address to;
        uint256 classId;
        uint256 amount;
    }

    struct MoneyMove {
        address from;
        address to;
        uint256 amount;
    }

    IERC1155 public immutable shares;
    IERC20 public immutable jpy;
    address public immutable clearingHouse;

    ShareMove[] public pendingShares;
    MoneyMove[] public pendingMoney;

    event Settled(uint256 shareMoves, uint256 moneyMoves, uint256 failedShares, uint256 failedMoney);
    event ShareDeliveryFailed(uint256 indexed index, address indexed to);
    event MoneyDeliveryFailed(uint256 indexed index, address indexed to);

    error NotClearingHouse();
    error NotSelf();
    error NothingPending();

    constructor(IERC1155 shares_, IERC20 jpy_, address clearingHouse_) {
        shares = shares_;
        jpy = jpy_;
        clearingHouse = clearingHouse_;
    }

    modifier onlyHouse() {
        if (msg.sender != clearingHouse) revert NotClearingHouse();
        _;
    }

    /// @notice One day's net settlement. Collection must succeed (sellers' shares, buyers' money);
    ///         deliveries are isolated.
    function settle(ShareMove[] calldata shareMoves, MoneyMove[] calldata moneyMoves) external onlyHouse {
        for (uint256 i; i < shareMoves.length; ++i) {
            shares.safeTransferFrom(shareMoves[i].from, address(this), shareMoves[i].classId, shareMoves[i].amount, "");
        }
        for (uint256 i; i < moneyMoves.length; ++i) {
            require(jpy.transferFrom(moneyMoves[i].from, address(this), moneyMoves[i].amount), "collect");
        }
        uint256 failedS;
        uint256 failedM;
        for (uint256 i; i < shareMoves.length; ++i) {
            ShareMove calldata m = shareMoves[i];
            try this.deliverShares(m.to, m.classId, m.amount) {}
            catch {
                pendingShares.push(m);
                emit ShareDeliveryFailed(pendingShares.length - 1, m.to);
                failedS++;
            }
        }
        for (uint256 i; i < moneyMoves.length; ++i) {
            MoneyMove calldata m = moneyMoves[i];
            try this.deliverMoney(m.to, m.amount) {}
            catch {
                pendingMoney.push(m);
                emit MoneyDeliveryFailed(pendingMoney.length - 1, m.to);
                failedM++;
            }
        }
        emit Settled(shareMoves.length, moneyMoves.length, failedS, failedM);
    }

    function retryShares(uint256 index) external onlyHouse {
        ShareMove memory m = pendingShares[index];
        if (m.amount == 0) revert NothingPending();
        delete pendingShares[index];
        shares.safeTransferFrom(address(this), m.to, m.classId, m.amount, "");
    }

    function retryMoney(uint256 index) external onlyHouse {
        MoneyMove memory m = pendingMoney[index];
        if (m.amount == 0) revert NothingPending();
        delete pendingMoney[index];
        require(jpy.transfer(m.to, m.amount), "deliver");
    }

    /// @dev Self-calls only, so that `settle` can isolate each delivery.
    function deliverShares(address to, uint256 classId, uint256 amount) external {
        if (msg.sender != address(this)) revert NotSelf();
        shares.safeTransferFrom(address(this), to, classId, amount, "");
    }

    function deliverMoney(address to, uint256 amount) external {
        if (msg.sender != address(this)) revert NotSelf();
        require(jpy.transfer(to, amount), "deliver");
    }
}
