// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {OfficialContractRegistry} from "../../src/core/OfficialContractRegistry.sol";
import {IOfficialContractRegistry} from "../../src/interfaces/IOfficialContractRegistry.sol";
import {ResidentLink} from "../../src/core/ResidentLink.sol";
import {RegisteredJPY} from "../../src/core/RegisteredJPY.sol";
import {SuccessorMigration, IMigratableJPY} from "../../src/core/SuccessorMigration.sol";
import {Kinds} from "../../src/core/Kinds.sol";
import {RealEstateToken} from "../../src/assets/RealEstateToken.sol";
import {ShareToken} from "../../src/assets/ShareToken.sol";
import {ClearingContract} from "../../src/assets/ClearingContract.sol";

/// @notice Minimal tests for phase 5: real estate, shares and clearing.
contract AssetsTest is Test {
    address soumusho = makeAddr("soumusho");
    address city = makeAddr("city");
    address bureau = makeAddr("bureau");
    address fsa = makeAddr("fsa");
    address court = makeAddr("court");
    address issuer = makeAddr("issuer");
    address house = makeAddr("clearingHouse");

    address seller = makeAddr("seller");
    address buyer = makeAddr("buyer");
    address agentS = makeAddr("agentSeller");
    address agentB = makeAddr("agentBuyer");
    address bank = makeAddr("bank");
    address corp = makeAddr("corp");
    address heir1 = makeAddr("heir1");
    address heir2 = makeAddr("heir2");
    address stranger = makeAddr("stranger");

    OfficialContractRegistry registry;
    IOfficialContractRegistry reg;
    ResidentLink link;
    RegisteredJPY jpy;
    SuccessorMigration migration;
    RealEstateToken land;
    ShareToken shares;
    ClearingContract clearing;

    function setUp() public {
        registry = new OfficialContractRegistry(soumusho, 100_000, 30 days, 14 days);
        reg = IOfficialContractRegistry(address(registry));
        link = new ResidentLink("City", city, reg);
        jpy = new RegisteredJPY(issuer, reg);
        migration = new SuccessorMigration(soumusho, reg, IMigratableJPY(address(jpy)), 30 days);
        land = new RealEstateToken(bureau, reg, IERC20(address(jpy)));
        shares = new ShareToken(bureau, reg);
        clearing = new ClearingContract(IERC1155(address(shares)), IERC20(address(jpy)), house);

        vm.startPrank(soumusho);
        registry.setRegistrar(address(link), Kinds.RESIDENT);
        registry.setRegistrar(city, Kinds.RESIDENT);
        registry.setRegistrar(bureau, Kinds.CORPORATION);
        registry.setRegistrar(soumusho, Kinds.PUBLIC_CONTRACT);
        registry.setRegistrar(fsa, Kinds.FINANCIAL_VEHICLE);
        registry.register(address(land));
        registry.grantRole(registry.COURT_ROLE(), court);
        migration.grantRole(migration.COURT_ROLE(), court);
        migration.addAssetContract(address(land));
        migration.addAssetContract(address(shares));
        vm.stopPrank();

        vm.prank(fsa);
        registry.register(address(clearing));
        vm.prank(bureau);
        registry.register(corp);
        vm.startPrank(issuer);
        jpy.grantRole(jpy.MIGRATOR_ROLE(), address(migration));
        jpy.mint(buyer, 50_000_000);
        vm.stopPrank();
        vm.startPrank(bureau);
        land.grantRole(land.MIGRATOR_ROLE(), address(migration));
        shares.grantRole(shares.MIGRATOR_ROLE(), address(migration));
        vm.stopPrank();

        address[5] memory people = [seller, buyer, agentS, agentB, bank];
        vm.startPrank(city);
        for (uint256 i; i < people.length; ++i) {
            link.mint(people[i]);
        }
        link.mint(heir1);
        link.mint(heir2);
        vm.stopPrank();
    }

    function _one(address a) private pure returns (address[] memory arr) {
        arr = new address[](1);
        arr[0] = a;
    }

    function _mintHouse() private returns (uint256 id) {
        RealEstateToken.Parcel memory p;
        p.parcelHash = keccak256(abi.encode("1-2-3", bytes32("salt")));
        p.shareNumerator = 1;
        p.shareDenominator = 1;
        vm.prank(bureau);
        id = land.mint(seller, p, _one(agentS));
    }

    // ---------------- RealEstateToken ----------------

    function test_IndividualCannotReceiveWithoutAgent() public {
        RealEstateToken.Parcel memory p;
        p.shareNumerator = 1;
        p.shareDenominator = 1;
        vm.prank(bureau);
        vm.expectRevert(RealEstateToken.RecipientNeedsAgent.selector);
        land.mint(seller, p, new address[](0));
    }

    function test_TransferNeedsAgentApproval() public {
        uint256 id = _mintHouse();
        vm.prank(buyer);
        land.nameAgents(id, _one(agentB));
        vm.prank(seller); // a thief with only the owner's key gets this far
        vm.expectRevert(RealEstateToken.AgentApprovalMissing.selector);
        land.transferParcel(id, buyer);

        vm.prank(agentS);
        land.approveAsAgent(id, buyer);
        vm.prank(seller);
        land.transferParcel(id, buyer);
        assertEq(land.ownerOf(id), buyer);
        assertEq(land.agentsOf(id)[0], agentB);
    }

    function test_DirectTransferDisabled() public {
        uint256 id = _mintHouse();
        vm.prank(seller);
        vm.expectRevert(RealEstateToken.DirectTransferDisabled.selector);
        land.transferFrom(seller, buyer, id);
    }

    function test_AtomicSettlement() public {
        uint256 id = _mintHouse();
        vm.prank(buyer);
        land.nameAgents(id, _one(agentB));
        vm.prank(agentS);
        land.approveAsAgent(id, buyer);
        uint256[] memory ids = new uint256[](1);
        ids[0] = id;
        vm.startPrank(buyer);
        jpy.approve(address(land), 30_000_000);
        uint256 sid = land.openSettlement(seller, ids, 30_000_000, uint64(block.timestamp + 7 days));
        vm.stopPrank();
        vm.prank(seller);
        land.settle(sid);
        assertEq(land.ownerOf(id), buyer);
        assertEq(jpy.balanceOf(seller), 30_000_000);
    }

    function test_LienBlocksUntilLenderConsents() public {
        uint256 id = _mintHouse();
        vm.prank(agentS);
        land.approveAsAgent(id, bank); // owner's agent approves the mortgage
        vm.prank(bank);
        land.setLien(id, keccak256("mortgage"));

        vm.prank(buyer);
        land.nameAgents(id, _one(agentB));
        vm.prank(agentS);
        land.approveAsAgent(id, buyer);
        vm.prank(seller);
        vm.expectRevert(RealEstateToken.LenderConsentMissing.selector);
        land.transferParcel(id, buyer);
        vm.prank(bank);
        land.consentAsLender(id, buyer);
        vm.prank(seller);
        land.transferParcel(id, buyer);
    }

    function test_ForeclosureClearsLien() public {
        uint256 id = _mintHouse();
        vm.prank(agentS);
        land.approveAsAgent(id, bank);
        vm.prank(bank);
        land.setLien(id, keccak256("mortgage"));
        vm.prank(bureau);
        land.forceTransfer(id, buyer, keccak256("court-order"), keccak256("Foreclosure"), _one(agentB));
        (,,,, address lender,) = land.parcels(id);
        assertEq(lender, address(0));
        assertEq(land.ownerOf(id), buyer);
    }

    function test_DeathFreezesLandUntilHeavyPathSplitsShares() public {
        uint256 id = _mintHouse();
        vm.prank(city);
        link.burn(seller); // death
        vm.prank(agentS);
        land.approveAsAgent(id, buyer);
        vm.prank(seller); // a relative holding the key
        vm.expectRevert(RealEstateToken.HolderInactive.selector);
        land.transferParcel(id, buyer);

        address[] memory heirs = new address[](2);
        heirs[0] = heir1;
        heirs[1] = heir2;
        uint16[] memory bps = new uint16[](2);
        bps[0] = 5_000;
        bps[1] = 5_000;
        address[][] memory agents = new address[][](2);
        agents[0] = _one(agentB);
        agents[1] = _one(agentS);
        vm.prank(city);
        uint256 pid = migration.propose(seller, heirs, bps, abi.encode(agents));
        vm.prank(court);
        migration.approve(pid);
        vm.warp(block.timestamp + 30 days);
        migration.execute(pid);
        assertEq(land.balanceOf(heir1), 1);
        assertEq(land.balanceOf(heir2), 1);
        (, uint32 num, uint32 den,,,) = land.parcels(land.tokenOfOwnerByIndex(heir1, 0));
        assertEq(uint256(num) * 2, den); // a one-half share
    }

    // ---------------- ShareToken ----------------

    function _class(bool restricted) private returns (uint256 classId) {
        vm.prank(bureau);
        classId = shares.createClass(corp, restricted);
        vm.prank(corp);
        shares.issue(classId, seller, 1_000, keccak256("resolution"));
    }

    function test_OnlyCorporationIssuesAndHoldersMustBeEligible() public {
        uint256 classId = _class(false);
        vm.prank(stranger);
        vm.expectRevert(ShareToken.NotCorporation.selector);
        shares.issue(classId, stranger, 1, "");
        vm.prank(seller);
        vm.expectRevert(abi.encodeWithSelector(ShareToken.NotEligibleHolder.selector, stranger));
        shares.safeTransferFrom(seller, stranger, classId, 1, "");
    }

    function test_RestrictedClassNeedsApproval() public {
        uint256 classId = _class(true);
        vm.prank(seller);
        vm.expectRevert(ShareToken.RestrictedTransferNotApproved.selector);
        shares.safeTransferFrom(seller, buyer, classId, 10, "");
        vm.prank(corp);
        shares.approveRestrictedTransfer(classId, seller, buyer, 10);
        vm.prank(seller);
        shares.safeTransferFrom(seller, buyer, classId, 10, "");
    }

    function test_OperatorApprovalLapsesOnSuspension() public {
        _class(false);
        vm.prank(seller);
        shares.setApprovalForAll(address(clearing), true);
        assertTrue(shares.isApprovedForAll(seller, address(clearing)));
        vm.prank(city);
        registry.suspend(seller);
        assertFalse(shares.isApprovedForAll(seller, address(clearing)));
    }

    function test_ClearingIsolatesFailedDelivery() public {
        uint256 classId = _class(false);
        vm.prank(seller);
        shares.setApprovalForAll(address(clearing), true);
        vm.prank(buyer);
        jpy.approve(address(clearing), 1_000_000);

        ClearingContract.ShareMove[] memory sm = new ClearingContract.ShareMove[](2);
        sm[0] = ClearingContract.ShareMove(seller, buyer, classId, 100);
        sm[1] = ClearingContract.ShareMove(seller, stranger, classId, 50); // not eligible: fails alone
        ClearingContract.MoneyMove[] memory mm = new ClearingContract.MoneyMove[](1);
        mm[0] = ClearingContract.MoneyMove(buyer, seller, 150_000);
        vm.prank(house);
        clearing.settle(sm, mm);

        assertEq(shares.balanceOf(buyer, classId), 100);
        assertEq(jpy.balanceOf(seller), 150_000);
        assertEq(shares.balanceOf(address(clearing), classId), 50); // pending retry

        vm.prank(city);
        link.mint(stranger); // becomes eligible
        vm.prank(house);
        clearing.retryShares(0);
        assertEq(shares.balanceOf(stranger, classId), 50);
    }
}
