// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OfficialContractRegistry} from "../../src/core/OfficialContractRegistry.sol";
import {IOfficialContractRegistry} from "../../src/interfaces/IOfficialContractRegistry.sol";
import {ResidentLink} from "../../src/core/ResidentLink.sol";
import {RegisteredJPY} from "../../src/core/RegisteredJPY.sol";
import {Kinds} from "../../src/core/Kinds.sol";
import {CorporateRegistration} from "../../src/corporate/CorporateRegistration.sol";
import {CorporateMultisig} from "../../src/corporate/CorporateMultisig.sol";
import {PublicTreasury} from "../../src/public/PublicTreasury.sol";
import {AnchorRegistry} from "../../src/public/AnchorRegistry.sol";
import {CaseRecordRegistry} from "../../src/public/CaseRecordRegistry.sol";
import {IPoliticalFund} from "../../src/interfaces/IPoliticalFund.sol";

contract MockFund is IPoliticalFund {
    IERC20 public immutable jpy;
    uint256 public accounted;
    uint8 public lastCategory;

    constructor(IERC20 jpy_) {
        jpy = jpy_;
    }

    function contribute(uint256 amount, uint8 category, address) external {
        jpy.transferFrom(msg.sender, address(this), amount);
        accounted += amount;
        lastCategory = category;
    }
}

/// @notice Minimal tests for phase 2: corporations and public finance.
contract CorporateAndPublicTest is Test {
    address soumusho = makeAddr("soumusho");
    address city = makeAddr("city");
    address bureau = makeAddr("bureau"); // 法務局
    address fsa = makeAddr("fsa");
    address court = makeAddr("court");
    address issuer = makeAddr("issuer");
    address accountingOfficer = makeAddr("accountingOfficer");

    address o1 = makeAddr("officer1");
    address o2 = makeAddr("officer2");
    address o3 = makeAddr("officer3");
    address resident = makeAddr("resident");
    address stranger = makeAddr("stranger");

    OfficialContractRegistry registry;
    IOfficialContractRegistry reg;
    ResidentLink link;
    RegisteredJPY jpy;
    CorporateRegistration bureauReg;
    CorporateRegistration fsaReg;
    CorporateMultisig corp;
    PublicTreasury treasury;
    AnchorRegistry anchors;
    CaseRecordRegistry cases;

    function setUp() public {
        registry = new OfficialContractRegistry(soumusho, 100_000, 30 days, 14 days);
        reg = IOfficialContractRegistry(address(registry));
        link = new ResidentLink("City", city, reg);
        jpy = new RegisteredJPY(issuer, reg);
        bureauReg = new CorporateRegistration("Legal Affairs Bureau", bureau, reg);
        fsaReg = new CorporateRegistration("FSA", fsa, reg);

        vm.startPrank(soumusho);
        registry.setRegistrar(address(link), Kinds.RESIDENT);
        registry.setRegistrar(city, Kinds.RESIDENT);
        registry.setRegistrar(address(bureauReg), Kinds.CORPORATION);
        registry.setRegistrar(address(fsaReg), Kinds.CORPORATION);
        registry.setRegistrar(soumusho, Kinds.PUBLIC_CONTRACT);
        registry.grantRole(registry.COURT_ROLE(), court);
        vm.stopPrank();

        vm.startPrank(city);
        link.mint(o1);
        link.mint(o2);
        link.mint(o3);
        link.mint(resident);
        vm.stopPrank();

        address[] memory signers = new address[](3);
        signers[0] = o1;
        signers[1] = o2;
        signers[2] = o3;
        corp = new CorporateMultisig(signers, 2, reg, bureau, 30 days);

        vm.prank(bureau);
        bureauReg.mint(address(corp), _record("Example KK"));

        treasury = new PublicTreasury(reg, IERC20(address(jpy)), accountingOfficer);
        vm.prank(soumusho);
        registry.register(address(treasury));

        anchors = new AnchorRegistry(reg);
        cases = new CaseRecordRegistry(court);

        vm.startPrank(issuer);
        jpy.mint(address(corp), 1_000_000);
        jpy.mint(address(treasury), 10_000_000);
        jpy.mint(resident, 2_000_000);
        vm.stopPrank();
    }

    function _record(string memory name) private pure returns (CorporateRegistration.Record memory r) {
        r.name = name;
        r.registeredOffice = "Tokyo";
        r.purpose = "Software";
        r.capital = 10_000_000;
        r.officerNames = new string[](3);
        r.officerNames[0] = "Officer One";
        r.officerNames[1] = "Officer Two";
        r.officerNames[2] = "Officer Three";
        r.beneficialOwnerNames = new string[](1);
        r.beneficialOwnerNames[0] = "Officer One";
    }

    // ---------------- CorporateRegistration ----------------

    function test_RegistrationRegistersCorporationWithPublicRecord() public view {
        assertTrue(registry.isRegisteredAs(address(corp), Kinds.CORPORATION));
        assertEq(bureauReg.recordOf(address(corp)).name, "Example KK");
        assertEq(bureauReg.recordOf(address(corp)).beneficialOwnerNames[0], "Officer One");
    }

    function test_LosingOneLicenceKeepsOtherRegistration() public {
        vm.prank(fsa);
        fsaReg.mint(address(corp), _record("Example KK"));
        vm.prank(fsa);
        fsaReg.burn(address(corp)); // licence revoked (R1.1)
        assertTrue(registry.isRegistered(address(corp)));
    }

    // ---------------- CorporateMultisig ----------------

    function _submitPay(address signer) private returns (uint256 txId) {
        vm.prank(signer);
        txId = corp.submit(address(jpy), 0, abi.encodeCall(IERC20.transfer, (resident, 100_000)));
    }

    function test_MultisigExecutesWithThreshold() public {
        uint256 txId = _submitPay(o1);
        vm.prank(o2);
        corp.confirm(txId);
        corp.execute(txId);
        assertEq(jpy.balanceOf(resident), 2_100_000);
    }

    function test_DeceasedOfficerDoesNotCount() public {
        uint256 txId = _submitPay(o1);
        vm.prank(o2);
        corp.confirm(txId);
        vm.prank(city);
        link.burn(o2); // death
        vm.expectRevert(abi.encodeWithSelector(CorporateMultisig.NotEnoughConfirmations.selector, 1, 2));
        corp.execute(txId);
    }

    function test_RegistrarReplacesSignersAfterWaiting() public {
        address[] memory fresh = new address[](1);
        fresh[0] = resident;
        vm.prank(bureau);
        uint256 id = corp.proposeReplacement(fresh, 1);
        vm.expectRevert(CorporateMultisig.WaitingPeriodNotOver.selector);
        corp.executeReplacement(id);
        vm.warp(block.timestamp + 30 days);
        corp.executeReplacement(id);
        assertEq(corp.signers()[0], resident);
    }

    function test_ObjectionNeedsCourt() public {
        address[] memory fresh = new address[](1);
        fresh[0] = resident;
        vm.prank(bureau);
        uint256 id = corp.proposeReplacement(fresh, 1);
        vm.prank(o3);
        corp.objectToReplacement(id);
        vm.warp(block.timestamp + 30 days);
        vm.expectRevert(CorporateMultisig.ReplacementBlocked.selector);
        corp.executeReplacement(id);
        vm.prank(court);
        corp.courtApproveReplacement(id);
        corp.executeReplacement(id);
    }

    // ---------------- PublicTreasury ----------------

    function test_TaxToRegisteredTreasuryIsUncapped() public {
        vm.prank(resident);
        jpy.transfer(address(treasury), 1_500_000); // above the unregistered cap
    }

    function test_TreasuryPaysOnlyRegistered() public {
        vm.startPrank(accountingOfficer);
        treasury.pay(resident, 1_000, "pension", PublicTreasury.Tag.Normal);
        vm.expectRevert(abi.encodeWithSelector(PublicTreasury.PayeeNotRegistered.selector, stranger));
        treasury.pay(stranger, 1_000, "pension", PublicTreasury.Tag.Normal);
        vm.stopPrank();
    }

    function test_BatchFailureIsOwedAndRetried() public {
        address[] memory to = new address[](2);
        to[0] = resident;
        to[1] = stranger;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10_000;
        amounts[1] = 20_000;
        vm.prank(accountingOfficer);
        treasury.payMany(to, amounts, "benefit");
        assertEq(treasury.owed(stranger, "benefit"), 20_000);

        vm.prank(city);
        link.mint(stranger); // the payee becomes registered
        vm.prank(accountingOfficer);
        treasury.retry(stranger, "benefit");
        assertEq(jpy.balanceOf(stranger), 20_000);
    }

    function test_GrantIsAccountedPublicGrant() public {
        MockFund fund = new MockFund(IERC20(address(jpy)));
        vm.prank(soumusho);
        registry.register(address(fund)); // stands in for a factory-registered PoliticalFund
        vm.prank(accountingOfficer);
        treasury.grant(fund, 500_000, "party-grant");
        assertEq(fund.accounted(), 500_000);
        assertEq(fund.lastCategory(), 4);
    }

    // ---------------- AnchorRegistry ----------------

    function test_RegisteredAddressAnchors() public {
        vm.expectEmit(address(anchors));
        emit AnchorRegistry.Anchored(address(corp), keccak256("doc"), keccak256("CorporateResolution"), 0, "");
        vm.prank(address(corp));
        anchors.anchor(keccak256("doc"), keccak256("CorporateResolution"), 0, "");
    }

    function test_UnregisteredCannotAnchor() public {
        vm.prank(stranger);
        vm.expectRevert(AnchorRegistry.CallerNotRegistered.selector);
        anchors.anchor(keccak256("doc"), keccak256("AccessLog"), 0, "");
    }

    // ---------------- CaseRecordRegistry ----------------

    function test_ProtectedRecordNeedsReclassification() public {
        vm.startPrank(court);
        uint256 id = cases.register(
            "case-1", keccak256("Judgment"), keccak256("text"), CaseRecordRegistry.RetentionClass.Permanent, 0
        );
        vm.expectRevert(CaseRecordRegistry.ProtectedRecord.selector);
        cases.dispose(id);
        cases.reclassify(id, CaseRecordRegistry.RetentionClass.Standard);
        cases.dispose(id);
        vm.stopPrank();
    }
}
