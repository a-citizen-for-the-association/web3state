// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";
import {Kinds} from "../core/Kinds.sol";

/// @title Petition
/// @notice One per direct demand (provisional implementation). Fixed content hash, denominator,
///         threshold and period; an explicit eligible list kept by the election board; residents
///         sign themselves; the count is "signatures from currently listed addresses".
/// @dev Spec: docs/state-design/direct-demand/README.md; ADRs 0016, 0032 (F1: per-petition list kept).
contract Petition {
    enum DemandType {
        OrdinanceEnactment,
        Audit,
        AssemblyDissolution,
        MemberRecall,
        HeadRecall,
        OfficialRecall
    }

    IOfficialContractRegistry public immutable registry;
    address public immutable board;
    DemandType public immutable demandType;
    bytes32 public immutable contentHash;
    uint256 public immutable denominator;
    uint256 public immutable threshold;
    uint64 public immutable collectionStart;
    uint64 public immutable collectionEnd;

    mapping(address account => bool) public eligible;
    mapping(address account => bool) public signed;
    uint256 public signatureCount; // signatures from currently listed addresses
    uint64 public pausedAt; // 0 = not paused
    uint64 public totalPaused;

    event EligibleAdded(address indexed account);
    event EligibleRemoved(address indexed account);
    event Signed(address indexed signer);
    event Paused();
    event Resumed();

    error NotBoard();
    error NotResident(address account);
    error NotEligible();
    error AlreadySigned();
    error IsPaused();
    error OutsidePeriod();

    constructor(
        IOfficialContractRegistry registry_,
        address board_,
        DemandType demandType_,
        bytes32 contentHash_,
        uint256 denominator_,
        uint256 threshold_,
        uint64 start,
        uint64 end
    ) {
        registry = registry_;
        board = board_;
        demandType = demandType_;
        contentHash = contentHash_;
        denominator = denominator_;
        threshold = threshold_;
        collectionStart = start;
        collectionEnd = end;
    }

    modifier onlyBoard() {
        if (msg.sender != board) revert NotBoard();
        _;
    }

    function addEligible(address[] calldata accounts) external onlyBoard {
        for (uint256 i; i < accounts.length; ++i) {
            address a = accounts[i];
            if (!registry.isRegisteredAs(a, Kinds.RESIDENT)) revert NotResident(a);
            if (eligible[a]) continue;
            eligible[a] = true;
            if (signed[a]) signatureCount++; // restored (F2)
            emit EligibleAdded(a);
        }
    }

    function removeEligible(address[] calldata accounts) external onlyBoard {
        for (uint256 i; i < accounts.length; ++i) {
            address a = accounts[i];
            if (!eligible[a]) continue;
            eligible[a] = false;
            if (signed[a]) signatureCount--; // drops out of the count (F2)
            emit EligibleRemoved(a);
        }
    }

    function pause() external onlyBoard {
        if (pausedAt != 0) revert IsPaused();
        pausedAt = uint64(block.timestamp);
        emit Paused();
    }

    function resume() external onlyBoard {
        if (pausedAt == 0) revert IsPaused();
        totalPaused += uint64(block.timestamp) - pausedAt;
        pausedAt = 0;
        emit Resumed();
    }

    function sign() external {
        if (pausedAt != 0) revert IsPaused();
        if (block.timestamp < collectionStart || block.timestamp >= effectiveEnd()) revert OutsidePeriod();
        if (!eligible[msg.sender]) revert NotEligible();
        if (signed[msg.sender]) revert AlreadySigned();
        signed[msg.sender] = true;
        signatureCount++;
        emit Signed(msg.sender);
    }

    function effectiveEnd() public view returns (uint256) {
        return uint256(collectionEnd) + totalPaused;
    }

    function thresholdReached() external view returns (bool) {
        return signatureCount >= threshold;
    }
}

/// @title PetitionFactory
/// @notice One per election board; every petition runs the same code.
contract PetitionFactory {
    IOfficialContractRegistry public immutable registry;
    address public immutable board;

    event PetitionCreated(address indexed petition, Petition.DemandType demandType);

    error NotBoard();

    constructor(IOfficialContractRegistry registry_, address board_) {
        registry = registry_;
        board = board_;
    }

    function createPetition(
        Petition.DemandType demandType,
        bytes32 contentHash,
        uint256 denominator,
        uint256 threshold,
        uint64 start,
        uint64 end
    ) external returns (Petition petition) {
        if (msg.sender != board) revert NotBoard();
        petition = new Petition(registry, board, demandType, contentHash, denominator, threshold, start, end);
        emit PetitionCreated(address(petition), demandType);
    }
}
