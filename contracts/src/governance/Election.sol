// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {Kinds} from "../core/Kinds.sol";

/// @title Election
/// @notice One instance per election (provisional implementation).
///         **The cryptography is stubbed** (user decision, 2026-11-21): ballots are stored as
///         opaque ciphertext hashes and proofs are not verified; the trustee set publishes the
///         totals. The real design (one-hot encrypted ballots, homomorphic summation, threshold
///         decryption, ZK proofs) needs an audited library (backlog). Only the flow, eligibility
///         and double-vote rules are implemented. Seat allocation: top-K by votes (plurality /
///         SNTV); other methods are pluggable later.
/// @dev Spec: docs/state-design/voting/README.md; ADRs 0013, 0032 (R3.7, F1, F4).
///      Eligibility is decided per election from resident information at that time (F1);
///      grants are batched here as one possible way to issue them at scale.
contract Election {
    IOfficialContractRegistry public immutable registry;
    address public immutable board;
    address public immutable trustees;
    uint256 public immutable optionCount;
    uint256 public immutable seats;
    uint64 public immutable votingStart;
    uint64 public immutable votingEnd;

    mapping(address voter => bool) public hasRight;
    mapping(address voter => bool) public hasVoted;
    bytes32[] public ballots; // opaque ciphertext hashes
    uint256[] private _totals;
    bool public tallyPublished;

    event RightGranted(address indexed voter);
    event RightMoved(address indexed oldVoter, address indexed newVoter);
    event BallotCast(address indexed voter, bytes32 ballotHash);
    event TallyPublished(uint256[] totals);

    error NotBoard();
    error NotTrustees();
    error NotResident(address voter);
    error NoRight();
    error AlreadyVoted();
    error Suspended();
    error OutsideVotingPeriod();
    error VotingNotOver();
    error BadTally();
    error OldAddressAlreadyVoted();

    constructor(
        IOfficialContractRegistry registry_,
        address board_,
        address trustees_,
        uint256 optionCount_,
        uint256 seats_,
        uint64 votingStart_,
        uint64 votingEnd_
    ) {
        registry = registry_;
        board = board_;
        trustees = trustees_;
        optionCount = optionCount_;
        seats = seats_;
        votingStart = votingStart_;
        votingEnd = votingEnd_;
    }

    function grantVotingRights(address[] calldata voters) external {
        if (msg.sender != board) revert NotBoard();
        for (uint256 i; i < voters.length; ++i) {
            if (!registry.isRegisteredAs(voters[i], Kinds.RESIDENT)) revert NotResident(voters[i]);
            hasRight[voters[i]] = true;
            emit RightGranted(voters[i]);
        }
    }

    /// @notice Succession (F4): burn the old right and grant the new address, unless the old
    ///         address has already voted in this election.
    function moveRight(address oldVoter, address newVoter) external {
        if (msg.sender != board) revert NotBoard();
        if (hasVoted[oldVoter]) revert OldAddressAlreadyVoted();
        if (!hasRight[oldVoter]) revert NoRight();
        if (!registry.isRegisteredAs(newVoter, Kinds.RESIDENT)) revert NotResident(newVoter);
        hasRight[oldVoter] = false;
        hasRight[newVoter] = true;
        emit RightMoved(oldVoter, newVoter);
    }

    /// @param encryptedVector Opaque ciphertext (stub). @param proof Ignored (stub).
    function castBallot(bytes calldata encryptedVector, bytes calldata proof) external {
        proof; // stub: well-formedness proof not verified in the provisional implementation
        if (block.timestamp < votingStart || block.timestamp >= votingEnd) revert OutsideVotingPeriod();
        if (!hasRight[msg.sender]) revert NoRight();
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (!registry.isRegisteredAs(msg.sender, Kinds.RESIDENT)) revert NotResident(msg.sender); // R3.7
        if (registry.isSuspended(msg.sender)) revert Suspended();
        hasVoted[msg.sender] = true;
        bytes32 h = keccak256(encryptedVector);
        ballots.push(h);
        emit BallotCast(msg.sender, h);
    }

    /// @notice Stub: the trustee set publishes plaintext totals; the decryption proof is ignored.
    function publishTally(uint256[] calldata totals, bytes calldata proof) external {
        proof;
        if (msg.sender != trustees) revert NotTrustees();
        if (block.timestamp < votingEnd) revert VotingNotOver();
        if (tallyPublished || totals.length != optionCount) revert BadTally();
        uint256 sum;
        for (uint256 i; i < totals.length; ++i) {
            sum += totals[i];
        }
        if (sum > ballots.length) revert BadTally();
        _totals = totals;
        tallyPublished = true;
        emit TallyPublished(totals);
    }

    /// @notice Top-`seats` options by votes (ties broken by lower index).
    function computeResult() external view returns (uint256[] memory winners) {
        uint256[] memory t = _totals;
        winners = new uint256[](seats);
        bool[] memory taken = new bool[](t.length);
        for (uint256 s; s < seats; ++s) {
            uint256 best = type(uint256).max;
            for (uint256 i; i < t.length; ++i) {
                if (!taken[i] && (best == type(uint256).max || t[i] > t[best])) best = i;
            }
            taken[best] = true;
            winners[s] = best;
        }
    }

    function totals() external view returns (uint256[] memory) {
        return _totals;
    }
}

/// @title ElectionFactory
/// @notice One per election board; deploys an `Election` per election (R4.3).
contract ElectionFactory {
    IOfficialContractRegistry public immutable registry;
    address public immutable board;

    event ElectionCreated(address indexed election);

    error NotBoard();

    constructor(IOfficialContractRegistry registry_, address board_) {
        registry = registry_;
        board = board_;
    }

    function createElection(address trustees, uint256 optionCount, uint256 seats, uint64 start, uint64 end)
        external
        returns (Election election)
    {
        if (msg.sender != board) revert NotBoard();
        election = new Election(registry, board, trustees, optionCount, seats, start, end);
        emit ElectionCreated(address(election));
    }
}
