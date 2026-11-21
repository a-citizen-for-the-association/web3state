// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

/// @title Kinds
/// @notice Identifiers shared by the registry and the contracts that query it.
/// @dev See docs/state-design/certified-stablecoin/README.md ("OfficialContractRegistry: canonical definition").
library Kinds {
    // ---- Lookup A: official contract kinds (written by 総務省 only) ----
    bytes32 internal constant RESIDENT_LINK_CONTRACT = keccak256("ResidentLink");
    bytes32 internal constant CORPORATE_REGISTRATION_CONTRACT = keccak256("CorporateRegistration");
    bytes32 internal constant PUBLIC_TREASURY_CONTRACT = keccak256("PublicTreasury");

    // ---- Lookup B: registration kinds (one flag per kind and registrar) ----
    bytes32 internal constant RESIDENT = keccak256("Resident");
    bytes32 internal constant CORPORATION = keccak256("Corporation");
    bytes32 internal constant PUBLIC_CONTRACT = keccak256("PublicContract");
    bytes32 internal constant NATIONAL_ABROAD = keccak256("NationalAbroad");
    bytes32 internal constant FOREIGN_INVESTOR = keccak256("ForeignInvestor");
    bytes32 internal constant FINANCIAL_VEHICLE = keccak256("FinancialVehicle");
    bytes32 internal constant FACTORY_DEPLOYED = keccak256("FactoryDeployed");
}
