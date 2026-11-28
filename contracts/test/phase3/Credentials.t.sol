// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {Test} from "forge-std/Test.sol";
import {OfficialContractRegistry} from "../../src/core/OfficialContractRegistry.sol";
import {IOfficialContractRegistry} from "../../src/interfaces/IOfficialContractRegistry.sol";
import {ResidentLink} from "../../src/core/ResidentLink.sol";
import {Kinds} from "../../src/core/Kinds.sol";
import {SoulboundCredential} from "../../src/credentials/SoulboundCredential.sol";
import {VaccinationCoupon, IResidentLinkOwn} from "../../src/credentials/VaccinationCoupon.sol";
import {AgeCredential} from "../../src/credentials/AgeCredential.sol";

/// @notice Minimal tests for phase 3: credentials.
contract CredentialsTest is Test {
    address soumusho = makeAddr("soumusho");
    address city = makeAddr("city");
    address mofa = makeAddr("mofa");
    address school = makeAddr("school");
    address company = makeAddr("company");
    address hospital = makeAddr("hospital");

    address alice = makeAddr("alice");
    address aliceNew = makeAddr("aliceNew");
    address overseasHire = makeAddr("overseasHire");

    OfficialContractRegistry registry;
    IOfficialContractRegistry reg;
    ResidentLink link;
    ResidentLink fakeLink;
    SoulboundCredential passport;
    SoulboundCredential diploma;
    SoulboundCredential employeeId;
    VaccinationCoupon coupon;
    AgeCredential age;

    function setUp() public {
        registry = new OfficialContractRegistry(soumusho, 100_000, 30 days, 14 days);
        reg = IOfficialContractRegistry(address(registry));
        link = new ResidentLink("City", city, reg);
        fakeLink = new ResidentLink("Fake", city, reg);
        passport = new SoulboundCredential("Passport", "PASS", mofa, reg, false);
        diploma = new SoulboundCredential("Diploma", "DIPL", school, reg, true);
        employeeId = new SoulboundCredential("Employee ID", "EMPID", company, reg, false);
        coupon = new VaccinationCoupon("Coupon", city, reg, IResidentLinkOwn(address(link)));
        age = new AgeCredential(city, reg);

        vm.startPrank(soumusho);
        registry.setContractKind(address(link), Kinds.RESIDENT_LINK_CONTRACT);
        registry.setRegistrar(address(link), Kinds.RESIDENT);
        registry.setRegistrar(address(fakeLink), Kinds.RESIDENT); // registrar, but not a listed contract kind
        registry.setRegistrar(soumusho, Kinds.CORPORATION); // stands in for a corporate registrar
        vm.stopPrank();

        vm.startPrank(city);
        link.mint(alice);
        link.mint(aliceNew);
        coupon.grantRole(coupon.VACCINATOR_ROLE(), hospital);
        vm.stopPrank();
        vm.prank(soumusho);
        registry.register(hospital);
    }

    function test_DiplomaRequiresGenuineResidentLink() public {
        vm.startPrank(school);
        vm.expectRevert(SoulboundCredential.NotAResidentLinkContract.selector);
        diploma.mint(alice, address(fakeLink));
        diploma.mint(alice, address(link));
        vm.stopPrank();
        assertTrue(diploma.holds(alice));
    }

    function test_EmployeeIdNeedsNoResidentLink() public {
        vm.prank(company);
        employeeId.mint(overseasHire, address(0));
        assertTrue(employeeId.holds(overseasHire));
    }

    function test_CredentialIsSoulbound() public {
        vm.prank(mofa);
        passport.mint(alice, address(0));
        uint256 id = passport.tokenOf(alice);
        vm.prank(alice);
        vm.expectRevert(SoulboundCredential.Soulbound.selector);
        passport.transferFrom(alice, aliceNew, id);
    }

    function test_ReissueToSuccessorAndBurnOnDeath() public {
        vm.startPrank(school);
        diploma.mint(alice, address(link));
        diploma.reissue(alice, aliceNew, keccak256("migration-1"));
        assertFalse(diploma.holds(alice));
        assertTrue(diploma.holds(aliceNew));
        diploma.burn(aliceNew); // death
        vm.stopPrank();
        assertFalse(diploma.holds(aliceNew));
    }

    function test_VaccinationFlowAndPermanence() public {
        vm.prank(city);
        coupon.mint(alice);
        vm.prank(hospital);
        coupon.markVaccinated(alice);
        vm.prank(city);
        vm.expectRevert(VaccinationCoupon.CannotBurnVaccinated.selector);
        coupon.burn(alice, false);

        vm.prank(city);
        coupon.reissue(alice, aliceNew, keccak256("migration-1")); // keeps Vaccinated (F5)
        assertEq(uint8(coupon.statusOfHolder(aliceNew)), uint8(VaccinationCoupon.Status.Vaccinated));
        vm.prank(city);
        coupon.burn(aliceNew, true); // death
    }

    function test_UnregisteredVaccinatorRejected() public {
        vm.prank(city);
        coupon.mint(alice);
        vm.prank(soumusho);
        registry.unregister(hospital); // the hospital closed
        vm.prank(hospital);
        vm.expectRevert(VaccinationCoupon.VaccinatorNotRegistered.selector);
        coupon.markVaccinated(alice);
    }

    function test_AgeCheckNeedsRegistrationAndToken() public {
        address[] memory batch = new address[](1);
        batch[0] = alice;
        vm.prank(city);
        age.mintBatch(batch, 20);
        assertTrue(age.isOfAge(alice, 20));
        assertFalse(age.isOfAge(alice, 18)); // other thresholds are separate types
        vm.prank(city);
        link.burn(alice); // no registration left
        assertFalse(age.isOfAge(alice, 20));
    }
}
