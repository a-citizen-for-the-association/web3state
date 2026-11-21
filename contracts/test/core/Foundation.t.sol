// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {Test} from "forge-std/Test.sol";
import {OfficialContractRegistry} from "../../src/core/OfficialContractRegistry.sol";
import {IOfficialContractRegistry} from "../../src/interfaces/IOfficialContractRegistry.sol";
import {ResidentLink} from "../../src/core/ResidentLink.sol";
import {RegisteredJPY} from "../../src/core/RegisteredJPY.sol";
import {SuccessorMigration, IMigratableJPY} from "../../src/core/SuccessorMigration.sol";
import {Kinds} from "../../src/core/Kinds.sol";

/// @notice Minimal tests for the foundation (phase 1): registry, ResidentLink, the ADR 0031
///         transfer rule, and successor migration.
contract FoundationTest is Test {
    uint256 constant CAP = 100_000; // yen per period
    uint64 constant PERIOD = 30 days;
    uint64 constant SUSPENSION_WINDOW = 14 days;
    uint64 constant WAITING = 30 days;

    address soumusho = makeAddr("soumusho");
    address cityA = makeAddr("cityA");
    address cityB = makeAddr("cityB");
    address court = makeAddr("court");
    address electionBoard = makeAddr("electionBoard");
    address fsa = makeAddr("fsa");
    address issuer = makeAddr("issuer");

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");
    address stranger = makeAddr("stranger"); // unregistered
    address exchanger = makeAddr("exchanger");

    OfficialContractRegistry registry;
    ResidentLink linkA;
    ResidentLink linkB;
    RegisteredJPY jpy;
    SuccessorMigration migration;

    function setUp() public {
        registry = new OfficialContractRegistry(soumusho, CAP, PERIOD, SUSPENSION_WINDOW);
        IOfficialContractRegistry reg = IOfficialContractRegistry(address(registry));
        linkA = new ResidentLink("City A", cityA, reg);
        linkB = new ResidentLink("City B", cityB, reg);
        jpy = new RegisteredJPY(issuer, reg);
        migration = new SuccessorMigration(soumusho, reg, IMigratableJPY(address(jpy)), WAITING);

        vm.startPrank(soumusho);
        registry.setContractKind(address(linkA), Kinds.RESIDENT_LINK_CONTRACT);
        registry.setContractKind(address(linkB), Kinds.RESIDENT_LINK_CONTRACT);
        registry.setRegistrar(address(linkA), Kinds.RESIDENT);
        registry.setRegistrar(address(linkB), Kinds.RESIDENT);
        registry.setRegistrar(cityA, Kinds.RESIDENT); // the municipality itself (suspension, heavy path)
        registry.setRegistrar(fsa, Kinds.FINANCIAL_VEHICLE);
        registry.grantRole(registry.VIP_MARKER_ROLE(), electionBoard);
        registry.grantRole(registry.EXEMPT_MARKER_ROLE(), fsa);
        registry.grantRole(registry.COURT_ROLE(), court);
        migration.grantRole(migration.COURT_ROLE(), court);
        vm.stopPrank();

        vm.startPrank(issuer);
        jpy.grantRole(jpy.MIGRATOR_ROLE(), address(migration));
        vm.stopPrank();

        vm.startPrank(cityA);
        linkA.mint(alice);
        linkA.mint(bob);
        linkA.mint(carol);
        vm.stopPrank();

        vm.startPrank(issuer);
        jpy.mint(alice, 1_000_000);
        jpy.mint(stranger, 50_000);
        vm.stopPrank();
    }

    // ---------------- registry and ResidentLink ----------------

    function test_MintRegistersAndBurnUnregisters() public {
        assertTrue(registry.isRegisteredAs(alice, Kinds.RESIDENT));
        vm.prank(cityA);
        linkA.burn(alice);
        assertFalse(registry.isRegistered(alice));
        assertTrue(linkA.everIssued(alice));
    }

    function test_MoveMintsBeforeBurnSoNoGap() public {
        vm.prank(cityB);
        linkB.mint(alice); // new municipality first (R3.8)
        vm.prank(cityA);
        linkA.burn(alice);
        assertTrue(registry.isRegistered(alice));
        assertEq(registry.flagCount(alice), 1);
    }

    function test_ResidentLinkIsSoulbound() public {
        uint256 id = linkA.tokenOf(alice);
        vm.prank(alice);
        vm.expectRevert(ResidentLink.Soulbound.selector);
        linkA.transferFrom(alice, bob, id);
    }

    function test_OnlyRegistrarsWriteFlags() public {
        vm.prank(stranger);
        vm.expectRevert(OfficialContractRegistry.NotRegistrar.selector);
        registry.register(stranger);
    }

    // ---------------- transfer rule (ADR 0031) ----------------

    function test_RegisteredToRegisteredIsFree() public {
        vm.prank(alice);
        jpy.transfer(bob, 500_000);
        assertEq(jpy.balanceOf(bob), 500_000);
    }

    function test_RegisteredToUnregisteredWithinCap() public {
        vm.prank(alice);
        jpy.transfer(stranger, CAP);
        assertEq(jpy.balanceOf(stranger), 50_000 + CAP);
    }

    function test_SplittingDoesNotBypassCap() public {
        vm.startPrank(alice);
        jpy.transfer(stranger, CAP / 2);
        jpy.transfer(stranger, CAP / 2);
        vm.expectRevert(abi.encodeWithSelector(RegisteredJPY.UnregisteredCapExceeded.selector, CAP, 1, CAP));
        jpy.transfer(stranger, 1);
        vm.stopPrank();
    }

    function test_CapResetsNextPeriod() public {
        vm.prank(alice);
        jpy.transfer(stranger, CAP);
        vm.warp(block.timestamp + PERIOD);
        vm.prank(alice);
        jpy.transfer(stranger, CAP);
    }

    function test_VipCannotSendToUnregistered() public {
        vm.prank(electionBoard);
        registry.setVip(alice, true);
        vm.prank(alice);
        vm.expectRevert(RegisteredJPY.VipCannotSendToUnregistered.selector);
        jpy.transfer(stranger, 1);
        vm.prank(alice);
        jpy.transfer(bob, 1); // still free to registered addresses
    }

    function test_ExemptExchangerHasNoCap() public {
        vm.prank(fsa);
        registry.register(exchanger);
        vm.prank(fsa);
        registry.setExempt(exchanger, true);
        vm.prank(issuer);
        jpy.mint(exchanger, 10_000_000);
        vm.prank(exchanger);
        jpy.transfer(stranger, 5_000_000);
    }

    function test_UnregisteredSendsFreely() public {
        vm.prank(stranger);
        jpy.transfer(alice, 50_000);
        assertEq(jpy.balanceOf(stranger), 0);
    }

    function test_SuspendedSenderBlockedUntilLapse() public {
        vm.prank(cityA);
        registry.suspend(alice);
        vm.prank(alice);
        vm.expectRevert(RegisteredJPY.SenderSuspended.selector);
        jpy.transfer(bob, 1);

        vm.warp(block.timestamp + SUSPENSION_WINDOW); // no court confirmation: lapses
        vm.prank(alice);
        jpy.transfer(bob, 1);
    }

    function test_ConfirmedSuspensionDoesNotLapse() public {
        vm.prank(cityA);
        registry.suspend(alice);
        vm.prank(court);
        registry.confirmSuspension(alice);
        vm.warp(block.timestamp + SUSPENSION_WINDOW + 1);
        assertTrue(registry.isSuspended(alice));
    }

    // ---------------- successor migration ----------------

    function _heirs() private view returns (address[] memory s, uint16[] memory b) {
        s = new address[](2);
        s[0] = bob;
        s[1] = carol;
        b = new uint16[](2);
        b[0] = 6_000;
        b[1] = 4_000;
    }

    function test_HeavyPathAfterDeathSplitsToHeirs() public {
        vm.prank(cityA);
        linkA.burn(alice); // death
        (address[] memory s, uint16[] memory b) = _heirs();
        vm.prank(cityA);
        uint256 id = migration.propose(alice, s, b, "");
        vm.prank(court);
        migration.approve(id);

        vm.expectRevert(SuccessorMigration.WaitingPeriodNotOver.selector);
        migration.execute(id);

        vm.warp(block.timestamp + WAITING);
        migration.execute(id);
        assertEq(jpy.balanceOf(bob), 600_000);
        assertEq(jpy.balanceOf(carol), 400_000);
        assertEq(jpy.balanceOf(alice), 0);
    }

    function test_ActiveAddressCannotBeProposed() public {
        (address[] memory s, uint16[] memory b) = _heirs();
        vm.prank(cityA);
        vm.expectRevert(SuccessorMigration.AddressIsActive.selector);
        migration.propose(alice, s, b, "");
    }

    function test_OldAddressCanVeto() public {
        vm.prank(cityA);
        linkA.burn(alice);
        (address[] memory s, uint16[] memory b) = _heirs();
        vm.prank(cityA);
        uint256 id = migration.propose(alice, s, b, "");
        vm.prank(court);
        migration.approve(id);
        vm.prank(alice);
        migration.veto(id);
        vm.warp(block.timestamp + WAITING);
        vm.expectRevert(SuccessorMigration.InvalidState.selector);
        migration.execute(id);
    }

    function test_SuspendedAddressCannotVetoAndFundsMove() public {
        vm.prank(cityA);
        registry.suspend(alice); // key theft (R3.1)
        vm.prank(court);
        registry.confirmSuspension(alice);
        (address[] memory s, uint16[] memory b) = _heirs();
        vm.prank(cityA);
        uint256 id = migration.propose(alice, s, b, "");
        vm.prank(court);
        migration.approve(id);
        vm.prank(alice); // the thief holds the key
        vm.expectRevert(SuccessorMigration.SuspendedCannotVeto.selector);
        migration.veto(id);
        vm.warp(block.timestamp + WAITING);
        migration.execute(id);
        assertEq(jpy.balanceOf(alice), 0);
    }

    function test_LightPathNeedsRegistrarConfirmation() public {
        vm.prank(alice);
        migration.requestLight(bob);
        vm.prank(stranger);
        vm.expectRevert(SuccessorMigration.NotRegistrar.selector);
        migration.confirmLight(alice);
        vm.prank(cityA); // a registrar of alice's kind
        migration.confirmLight(alice);
        assertEq(jpy.balanceOf(bob), 1_000_000);
    }
}
