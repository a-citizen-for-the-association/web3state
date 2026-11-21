// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title OfficialContractRegistry
/// @notice The single registry operated by 総務省 (provisional implementation).
///         Lookup A: which contracts are genuine official ones.
///         Lookup B: which addresses are registered, as one flag per registrar (an address is
///         registered while any flag is set), plus the VIP, suspended and exempt marks.
/// @dev Spec: docs/state-design/certified-stablecoin/README.md; ADRs 0015, 0020, 0031, 0032.
contract OfficialContractRegistry is AccessControl {
    /// @notice Writes the VIP mark (election boards, the Cabinet Office).
    bytes32 public constant VIP_MARKER_ROLE = keccak256("VIP_MARKER_ROLE");
    /// @notice Writes the exempt mark for licensed exchangers and issuers (the FSA).
    bytes32 public constant EXEMPT_MARKER_ROLE = keccak256("EXEMPT_MARKER_ROLE");
    /// @notice Confirms a suspension so that it does not lapse (courts).
    bytes32 public constant COURT_ROLE = keccak256("COURT_ROLE");

    // ---- Lookup A ----
    mapping(address contractAddress => bytes32 kind) public kindOf;

    // ---- Lookup B ----
    /// @notice The registration kind each registrar may write (zero = not a registrar).
    mapping(address registrar => bytes32 kind) public registrarKind;
    mapping(address account => mapping(address registrar => bool)) public hasFlag;
    mapping(address account => uint256) public flagCount;
    mapping(address account => mapping(bytes32 kind => uint256)) public kindCount;

    // ---- Marks ----
    mapping(address account => bool) public isVip;
    mapping(address account => bool) public isExempt;
    mapping(address account => uint64) public suspendedAt;
    mapping(address account => bool) public suspensionConfirmed;

    // ---- Legal parameters ----
    /// @notice Cumulative cap per sender per period on sending to unregistered addresses.
    uint256 public unregisteredCap;
    /// @notice Length of the cap period in seconds (e.g. 30 days).
    uint64 public capPeriod;
    /// @notice A suspension lapses unless a court confirms it within this many seconds.
    uint64 public suspensionWindow;

    event ContractKindSet(address indexed contractAddress, bytes32 kind);
    event RegistrarSet(address indexed registrar, bytes32 kind);
    event Registered(address indexed account, address indexed registrar, bytes32 kind);
    event Unregistered(address indexed account, address indexed registrar, bytes32 kind);
    event VipSet(address indexed account, bool vip);
    event ExemptSet(address indexed account, bool exempt);
    event Suspended(address indexed account, address indexed registrar);
    event SuspensionConfirmed(address indexed account);
    event SuspensionLifted(address indexed account);
    event ParametersSet(uint256 unregisteredCap, uint64 capPeriod, uint64 suspensionWindow);

    error NotRegistrar();
    error AlreadyFlagged();
    error NotFlagged();
    error ZeroPeriod();

    constructor(address soumusho, uint256 cap, uint64 period, uint64 window) {
        _grantRole(DEFAULT_ADMIN_ROLE, soumusho);
        _setParameters(cap, period, window);
    }

    // ---------------- Lookup A (総務省 only) ----------------

    function setContractKind(address contractAddress, bytes32 kind) external onlyRole(DEFAULT_ADMIN_ROLE) {
        kindOf[contractAddress] = kind;
        emit ContractKindSet(contractAddress, kind);
    }

    function setRegistrar(address registrar, bytes32 kind) external onlyRole(DEFAULT_ADMIN_ROLE) {
        registrarKind[registrar] = kind;
        emit RegistrarSet(registrar, kind);
    }

    function setParameters(uint256 cap, uint64 period, uint64 window) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setParameters(cap, period, window);
    }

    // ---------------- Lookup B (each registrar writes its own flag) ----------------

    function register(address account) external {
        bytes32 kind = _requireRegistrar();
        if (hasFlag[account][msg.sender]) revert AlreadyFlagged();
        hasFlag[account][msg.sender] = true;
        flagCount[account] += 1;
        kindCount[account][kind] += 1;
        emit Registered(account, msg.sender, kind);
    }

    function unregister(address account) external {
        bytes32 kind = _requireRegistrar();
        if (!hasFlag[account][msg.sender]) revert NotFlagged();
        hasFlag[account][msg.sender] = false;
        flagCount[account] -= 1;
        kindCount[account][kind] -= 1;
        emit Unregistered(account, msg.sender, kind);
    }

    /// @notice True when `registrar` writes a kind that `account` currently holds.
    function isRegistrarOfKind(address account, address registrar) public view returns (bool) {
        bytes32 kind = registrarKind[registrar];
        return kind != bytes32(0) && kindCount[account][kind] > 0;
    }

    function isRegistered(address account) public view returns (bool) {
        return flagCount[account] > 0;
    }

    function isRegisteredAs(address account, bytes32 kind) external view returns (bool) {
        return kindCount[account][kind] > 0;
    }

    // ---------------- Marks ----------------

    function setVip(address account, bool vip) external onlyRole(VIP_MARKER_ROLE) {
        isVip[account] = vip;
        emit VipSet(account, vip);
    }

    function setExempt(address account, bool exempt) external onlyRole(EXEMPT_MARKER_ROLE) {
        isExempt[account] = exempt;
        emit ExemptSet(account, exempt);
    }

    /// @notice Suspends an address on an in-person key-theft report (R3.1). Only a registrar of
    ///         a kind the account is registered as (the registrar of its kind) may do this.
    function suspend(address account) external {
        if (!isRegistrarOfKind(account, msg.sender)) revert NotRegistrar();
        suspendedAt[account] = uint64(block.timestamp);
        suspensionConfirmed[account] = false;
        emit Suspended(account, msg.sender);
    }

    function confirmSuspension(address account) external onlyRole(COURT_ROLE) {
        if (suspendedAt[account] == 0) revert NotFlagged();
        suspensionConfirmed[account] = true;
        emit SuspensionConfirmed(account);
    }

    /// @notice Lifts a suspension (e.g. after the heavy path has run). Court only.
    function liftSuspension(address account) external onlyRole(COURT_ROLE) {
        suspendedAt[account] = 0;
        suspensionConfirmed[account] = false;
        emit SuspensionLifted(account);
    }

    /// @notice Suspended unless the suspension lapsed without court confirmation.
    function isSuspended(address account) public view returns (bool) {
        uint64 at = suspendedAt[account];
        if (at == 0) return false;
        if (suspensionConfirmed[account]) return true;
        return block.timestamp < uint256(at) + suspensionWindow;
    }

    // ---------------- internal ----------------

    function _requireRegistrar() private view returns (bytes32 kind) {
        kind = registrarKind[msg.sender];
        if (kind == bytes32(0)) revert NotRegistrar();
    }

    function _setParameters(uint256 cap, uint64 period, uint64 window) private {
        if (period == 0) revert ZeroPeriod();
        unregisteredCap = cap;
        capPeriod = period;
        suspensionWindow = window;
        emit ParametersSet(cap, period, window);
    }
}
