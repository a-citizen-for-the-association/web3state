// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {Kinds} from "../core/Kinds.sol";

/// @title Tender
/// @notice One per procurement (provisional implementation): commit-reveal sealed bids with a
///         deposit, a committed ceiling price, all revealed bids public, non-reveal deposits
///         forfeited to the treasury, and an award recorded with the contract hash.
/// @dev Spec: docs/state-design/procurement/README.md; ADRs 0022, 0032.
contract Tender {
    using SafeERC20 for IERC20;

    struct Bid {
        bytes32 commit;
        uint256 amount;
        bool revealed;
        bool settled; // deposit returned or forfeited
    }

    IOfficialContractRegistry public immutable registry;
    IERC20 public immutable jpy;
    address public immutable body;
    address public immutable treasury;
    bytes32 public immutable ceilingCommit;
    uint256 public immutable deposit;
    uint64 public immutable bidDeadline;
    uint64 public immutable revealDeadline;

    mapping(address bidder => Bid) public bids;
    address[] public bidders;
    uint256 public ceiling;
    bool public ceilingRevealed;
    address public winner;
    bytes32 public contractHash;

    event BidSubmitted(address indexed bidder);
    event BidRevealed(address indexed bidder, uint256 amount);
    event CeilingRevealed(uint256 amount);
    event DepositForfeited(address indexed bidder, uint256 amount);
    event Awarded(address indexed winner, bytes32 contractHash);

    error NotEligibleBidder();
    error AlreadyBid();
    error WrongPhase();
    error BadReveal();
    error NotBody();

    constructor(
        IOfficialContractRegistry registry_,
        IERC20 jpy_,
        address body_,
        address treasury_,
        bytes32 ceilingCommit_,
        uint256 deposit_,
        uint64 bidDeadline_,
        uint64 revealDeadline_
    ) {
        registry = registry_;
        jpy = jpy_;
        body = body_;
        treasury = treasury_;
        ceilingCommit = ceilingCommit_;
        deposit = deposit_;
        bidDeadline = bidDeadline_;
        revealDeadline = revealDeadline_;
    }

    function submitBid(bytes32 commit) external {
        if (block.timestamp >= bidDeadline) revert WrongPhase();
        if (!registry.isRegisteredAs(msg.sender, Kinds.CORPORATION) && !registry.isRegisteredAs(msg.sender, Kinds.RESIDENT)) {
            revert NotEligibleBidder();
        }
        if (bids[msg.sender].commit != bytes32(0)) revert AlreadyBid();
        bids[msg.sender].commit = commit;
        bidders.push(msg.sender);
        jpy.safeTransferFrom(msg.sender, address(this), deposit);
        emit BidSubmitted(msg.sender);
    }

    function revealBid(uint256 amount, bytes32 salt) external {
        if (block.timestamp < bidDeadline || block.timestamp >= revealDeadline) revert WrongPhase();
        Bid storage b = bids[msg.sender];
        if (b.revealed || b.commit != keccak256(abi.encode(msg.sender, amount, salt))) revert BadReveal();
        b.revealed = true;
        b.settled = true;
        b.amount = amount;
        jpy.safeTransfer(msg.sender, deposit);
        emit BidRevealed(msg.sender, amount);
    }

    function revealCeiling(uint256 amount, bytes32 salt) external {
        if (msg.sender != body) revert NotBody();
        if (block.timestamp < bidDeadline) revert WrongPhase();
        if (keccak256(abi.encode(amount, salt)) != ceilingCommit) revert BadReveal();
        ceiling = amount;
        ceilingRevealed = true;
        emit CeilingRevealed(amount);
    }

    function forfeit(address bidder) external {
        if (block.timestamp < revealDeadline) revert WrongPhase();
        Bid storage b = bids[bidder];
        if (b.commit == bytes32(0) || b.settled) revert WrongPhase();
        b.settled = true;
        jpy.safeTransfer(treasury, deposit);
        emit DepositForfeited(bidder, deposit);
    }

    function award(address winner_, bytes32 contractHash_) external {
        if (msg.sender != body) revert NotBody();
        if (block.timestamp < revealDeadline || !ceilingRevealed || winner != address(0)) revert WrongPhase();
        Bid storage b = bids[winner_];
        if (!b.revealed || b.amount > ceiling) revert BadReveal();
        winner = winner_;
        contractHash = contractHash_;
        emit Awarded(winner_, contractHash_);
    }

    /// @notice Lowest revealed bid within the ceiling (lowest-price awards are checked on-chain).
    function lowestValidBid() external view returns (address best, uint256 amount) {
        amount = type(uint256).max;
        for (uint256 i; i < bidders.length; ++i) {
            Bid storage b = bids[bidders[i]];
            if (b.revealed && b.amount <= ceiling && b.amount < amount) {
                best = bidders[i];
                amount = b.amount;
            }
        }
    }
}

/// @title TenderFactory
/// @notice One per procuring body; an approved registrar, so each Tender (which holds deposits)
///         is a registered address.
contract TenderFactory {
    IOfficialContractRegistry public immutable registry;
    IERC20 public immutable jpy;
    address public immutable body;
    address public immutable treasury;

    event TenderCreated(address indexed tender);

    error NotBody();

    constructor(IOfficialContractRegistry registry_, IERC20 jpy_, address body_, address treasury_) {
        registry = registry_;
        jpy = jpy_;
        body = body_;
        treasury = treasury_;
    }

    function createTender(bytes32 ceilingCommit, uint256 deposit, uint64 bidDeadline, uint64 revealDeadline)
        external
        returns (Tender tender)
    {
        if (msg.sender != body) revert NotBody();
        tender = new Tender(registry, jpy, body, treasury, ceilingCommit, deposit, bidDeadline, revealDeadline);
        registry.register(address(tender));
        emit TenderCreated(address(tender));
    }
}
