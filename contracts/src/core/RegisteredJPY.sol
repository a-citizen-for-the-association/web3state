// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IOfficialContractRegistry} from "../interfaces/IOfficialContractRegistry.sol";

/// @title RegisteredJPY
/// @notice Reference JPY stablecoin for tests, carrying the transfer rule every licensed JPY
///         stablecoin must implement (provisional implementation; the project does not issue
///         its own currency).
///
///         Rule (ADR 0031):
///         - registered -> unregistered: within a cumulative cap per sender per period;
///         - VIP sender: cap zero;
///         - exempt sender (licensed exchanger, issuer): no cap (the "recipient's own currency
///           only" rule is enforced off-chain by records and licence law);
///         - suspended sender: nothing leaves except through the successor-migration contract;
///         - everything else is free and checked afterwards.
/// @dev Spec: docs/state-design/certified-stablecoin/README.md ("Transfer rule").
contract RegisteredJPY is ERC20, AccessControl {
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    /// @notice The successor-migration contract, which may move funds out of suspended or
    ///         unregistered addresses on an executed heavy or light path.
    bytes32 public constant MIGRATOR_ROLE = keccak256("MIGRATOR_ROLE");

    IOfficialContractRegistry public immutable registry;

    /// @notice Amount each sender has sent to unregistered addresses, per period index.
    mapping(address sender => mapping(uint256 period => uint256)) public sentToUnregistered;

    bool private _migrating;

    error SenderSuspended();
    error VipCannotSendToUnregistered();
    error UnregisteredCapExceeded(uint256 alreadySent, uint256 amount, uint256 cap);

    constructor(address issuer, IOfficialContractRegistry registry_) ERC20("Registered JPY (test)", "rJPY") {
        registry = registry_;
        _grantRole(DEFAULT_ADMIN_ROLE, issuer);
        _grantRole(ISSUER_ROLE, issuer);
    }

    function decimals() public pure override returns (uint8) {
        return 0; // 1 token = 1 yen
    }

    function mint(address to, uint256 amount) external onlyRole(ISSUER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(ISSUER_ROLE) {
        _burn(from, amount);
    }

    /// @notice Moves funds for an executed successor migration (bypasses the sender checks,
    ///         which is the only way out of a suspended address).
    function migrate(address from, address to, uint256 amount) external onlyRole(MIGRATOR_ROLE) {
        _migrating = true;
        _transfer(from, to, amount);
        _migrating = false;
    }

    function currentPeriod() public view returns (uint256) {
        return block.timestamp / registry.capPeriod();
    }

    function remainingUnregisteredAllowance(address sender) external view returns (uint256) {
        if (registry.isVip(sender)) return 0;
        uint256 cap = registry.unregisteredCap();
        uint256 sent = sentToUnregistered[sender][currentPeriod()];
        return sent >= cap ? 0 : cap - sent;
    }

    function _update(address from, address to, uint256 value) internal override {
        // Mint, burn and migrations are not ordinary transfers.
        if (from != address(0) && to != address(0) && !_migrating) {
            _checkTransfer(from, to, value);
        }
        super._update(from, to, value);
    }

    function _checkTransfer(address from, address to, uint256 value) private {
        if (registry.isSuspended(from)) revert SenderSuspended();
        if (!registry.isRegistered(from) || registry.isRegistered(to)) return; // free
        if (registry.isExempt(from)) return;
        if (registry.isVip(from)) revert VipCannotSendToUnregistered();

        uint256 period = currentPeriod();
        uint256 sent = sentToUnregistered[from][period];
        uint256 cap = registry.unregisteredCap();
        if (sent + value > cap) revert UnregisteredCapExceeded(sent, value, cap);
        sentToUnregistered[from][period] = sent + value;
    }
}
