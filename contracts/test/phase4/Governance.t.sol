// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OfficialContractRegistry} from "../../src/core/OfficialContractRegistry.sol";
import {IOfficialContractRegistry} from "../../src/interfaces/IOfficialContractRegistry.sol";
import {ResidentLink} from "../../src/core/ResidentLink.sol";
import {RegisteredJPY} from "../../src/core/RegisteredJPY.sol";
import {Kinds} from "../../src/core/Kinds.sol";
import {PublicTreasury} from "../../src/public/PublicTreasury.sol";
import {Election, ElectionFactory} from "../../src/governance/Election.sol";
import {Petition, PetitionFactory} from "../../src/governance/Petition.sol";
import {PoliticalFund, PoliticalFundFactory} from "../../src/governance/PoliticalFund.sol";
import {Tender, TenderFactory} from "../../src/governance/Tender.sol";

/// @notice Minimal tests for phase 4: governance and politics.
contract GovernanceTest is Test {
    address soumusho = makeAddr("soumusho");
    address city = makeAddr("city");
    address issuer = makeAddr("issuer");
    address board = makeAddr("electionBoard");
    address trustees = makeAddr("trustees");
    address officer = makeAddr("accountingOfficer");
    address partyController = makeAddr("partyController");

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address aliceNew = makeAddr("aliceNew");
    address stranger = makeAddr("stranger");

    OfficialContractRegistry registry;
    IOfficialContractRegistry reg;
    ResidentLink link;
    RegisteredJPY jpy;
    PublicTreasury treasury;

    function setUp() public {
        vm.warp(1_767_225_600); // 2026-01-01T00:00:00Z
        registry = new OfficialContractRegistry(soumusho, 100_000, 30 days, 14 days);
        reg = IOfficialContractRegistry(address(registry));
        link = new ResidentLink("City", city, reg);
        jpy = new RegisteredJPY(issuer, reg);
        treasury = new PublicTreasury(reg, IERC20(address(jpy)), officer);

        vm.startPrank(soumusho);
        registry.setContractKind(address(link), Kinds.RESIDENT_LINK_CONTRACT);
        registry.setContractKind(address(treasury), Kinds.PUBLIC_TREASURY_CONTRACT);
        registry.setRegistrar(address(link), Kinds.RESIDENT);
        registry.setRegistrar(soumusho, Kinds.PUBLIC_CONTRACT);
        registry.register(address(treasury));
        vm.stopPrank();

        vm.startPrank(city);
        link.mint(alice);
        link.mint(bob);
        link.mint(aliceNew);
        vm.stopPrank();
        vm.startPrank(issuer);
        jpy.mint(alice, 1_000_000);
        jpy.mint(bob, 1_000_000);
        jpy.mint(address(treasury), 10_000_000);
        vm.stopPrank();
    }

    // ---------------- Election ----------------

    function _election() private returns (Election e) {
        ElectionFactory f = new ElectionFactory(reg, board);
        vm.prank(board);
        e = f.createElection(trustees, 3, 1, uint64(block.timestamp + 1 days), uint64(block.timestamp + 2 days));
        address[] memory voters = new address[](2);
        voters[0] = alice;
        voters[1] = bob;
        vm.prank(board);
        e.grantVotingRights(voters);
    }

    function test_ElectionFlowWithStubbedCrypto() public {
        Election e = _election();
        vm.warp(block.timestamp + 1 days);
        vm.prank(alice);
        e.castBallot("ciphertext-a", "");
        vm.prank(alice);
        vm.expectRevert(Election.AlreadyVoted.selector);
        e.castBallot("again", "");
        vm.prank(bob);
        e.castBallot("ciphertext-b", "");

        vm.warp(block.timestamp + 1 days);
        uint256[] memory totals = new uint256[](3);
        totals[2] = 2;
        vm.prank(trustees);
        e.publishTally(totals, "");
        assertEq(e.computeResult()[0], 2);
    }

    function test_DeceasedVoterCannotVote() public {
        Election e = _election();
        vm.prank(city);
        link.burn(bob);
        vm.warp(block.timestamp + 1 days);
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Election.NotResident.selector, bob));
        e.castBallot("x", "");
    }

    function test_MoveRightRefusedAfterOldVoted() public {
        Election e = _election();
        vm.warp(block.timestamp + 1 days);
        vm.prank(alice);
        e.castBallot("x", "");
        vm.prank(board);
        vm.expectRevert(Election.OldAddressAlreadyVoted.selector);
        e.moveRight(alice, aliceNew); // F4
    }

    // ---------------- Petition ----------------

    function test_PetitionCountsCurrentlyListedSigners() public {
        PetitionFactory f = new PetitionFactory(reg, board);
        vm.prank(board);
        Petition p = f.createPetition(
            Petition.DemandType.HeadRecall, keccak256("text"), 100, 2, uint64(block.timestamp), uint64(block.timestamp + 30 days)
        );
        address[] memory list = new address[](2);
        list[0] = alice;
        list[1] = bob;
        vm.prank(board);
        p.addEligible(list);
        vm.prank(alice);
        p.sign();
        vm.prank(bob);
        p.sign();
        assertTrue(p.thresholdReached());

        address[] memory moved = new address[](1);
        moved[0] = bob;
        vm.prank(board);
        p.removeEligible(moved); // moved out (F2)
        assertEq(p.signatureCount(), 1);

        vm.prank(stranger);
        vm.expectRevert(Petition.NotEligible.selector);
        p.sign();
    }

    // ---------------- PoliticalFund ----------------

    function _fund(uint8 orgType) private returns (PoliticalFund fund, PoliticalFundFactory f) {
        f = new PoliticalFundFactory(reg, IERC20(address(jpy)), board, address(treasury));
        vm.prank(soumusho);
        registry.setRegistrar(address(f), Kinds.FACTORY_DEPLOYED);
        vm.startPrank(board);
        f.setCap(Kinds.RESIDENT_LINK_CONTRACT, orgType, 0, 1_500_000);
        fund = f.createFund(partyController, orgType);
        vm.stopPrank();
    }

    function test_ResidentDonationWithinCapAndAccounted() public {
        (PoliticalFund fund,) = _fund(0);
        vm.startPrank(alice);
        jpy.approve(address(fund), 200_000);
        fund.contribute(200_000, 0, address(link));
        vm.stopPrank();
        assertEq(fund.accountedBalance(), 200_000);
        assertEq(fund.jstYear(block.timestamp), 2026);
    }

    function test_FakeIdentityContractRejected() public {
        (PoliticalFund fund,) = _fund(0);
        vm.prank(alice);
        vm.expectRevert(PoliticalFund.NotOfficialIdentity.selector);
        fund.contribute(1, 0, address(0xdead));
    }

    function test_UnaccountedTransferIsForfeitedToTreasury() public {
        (PoliticalFund fund,) = _fund(0);
        vm.prank(alice);
        jpy.transfer(address(fund), 50_000); // bypasses contribute
        uint256 before = jpy.balanceOf(address(treasury));
        fund.forfeitUnaccounted();
        assertEq(jpy.balanceOf(address(treasury)), before + 50_000);
        vm.prank(partyController);
        vm.expectRevert(PoliticalFund.ExceedsAccounted.selector);
        fund.spend(stranger, 1, "x");
    }

    function test_PartyGrantFromTreasury() public {
        (PoliticalFund fund,) = _fund(0);
        vm.prank(officer);
        treasury.grant(fund, 3_000_000, "party-grant"); // no cap for PublicGrant
        assertEq(fund.accountedBalance(), 3_000_000);
    }

    function test_DissolvedFundRejectsContributions() public {
        (PoliticalFund fund, PoliticalFundFactory f) = _fund(0);
        vm.prank(board);
        f.dissolve(address(fund));
        vm.prank(alice);
        vm.expectRevert(PoliticalFund.Inactive.selector);
        fund.contribute(1, 0, address(link));
    }

    // ---------------- Tender ----------------

    function test_TenderCommitRevealAwardAndForfeit() public {
        TenderFactory f = new TenderFactory(reg, IERC20(address(jpy)), officer, address(treasury));
        vm.prank(soumusho);
        registry.setRegistrar(address(f), Kinds.FACTORY_DEPLOYED);
        bytes32 ceilingCommit = keccak256(abi.encode(uint256(900_000), bytes32("c")));
        vm.prank(officer);
        Tender t = f.createTender(ceilingCommit, 10_000, uint64(block.timestamp + 1 days), uint64(block.timestamp + 2 days));

        vm.startPrank(alice);
        jpy.approve(address(t), 10_000);
        t.submitBid(keccak256(abi.encode(alice, uint256(800_000), bytes32("a"))));
        vm.stopPrank();
        vm.startPrank(bob);
        jpy.approve(address(t), 10_000);
        t.submitBid(keccak256(abi.encode(bob, uint256(700_000), bytes32("b"))));
        vm.stopPrank();
        vm.prank(stranger);
        vm.expectRevert(Tender.NotEligibleBidder.selector);
        t.submitBid(bytes32("s"));

        vm.warp(block.timestamp + 1 days);
        vm.prank(alice);
        t.revealBid(800_000, "a"); // bob never reveals
        vm.prank(officer);
        t.revealCeiling(900_000, "c");

        vm.warp(block.timestamp + 1 days);
        uint256 before = jpy.balanceOf(address(treasury));
        t.forfeit(bob);
        assertEq(jpy.balanceOf(address(treasury)), before + 10_000);
        (address best,) = t.lowestValidBid();
        assertEq(best, alice);
        vm.prank(officer);
        t.award(alice, keccak256("contract"));
    }
}
