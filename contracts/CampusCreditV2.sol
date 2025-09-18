// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CampusCreditV2
 * @dev Production-ready ERC-20 token with advanced features:
 * - Cap enforced on mint
 * - Pausable transfers
 * - Roles: ADMIN, MINTER, PAUSER
 * - Batch airdrop (gas-aware), custom errors
 */
contract CampusCreditV2 is ERC20, ERC20Burnable, ERC20Capped, ERC20Pausable, AccessControl {
    // Role constants
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // Custom errors for gas efficiency
    error CapExceeded();
    error ArrayLengthMismatch();

    /**
     * @dev Constructor sets up the token with cap, roles, and initial mint
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param cap_ Maximum supply in wei (18 decimals)
     * @param initialReceiver Address to receive initial mint
     * @param initialMint Amount to mint initially in wei
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 cap_, // in wei (18 decimals)
        address initialReceiver,
        uint256 initialMint // in wei
    )
        ERC20(name_, symbol_)
        ERC20Capped(cap_)
    {
        // Grant roles to deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        // Initial mint if specified
        if (initialMint > 0) {
            _mint(initialReceiver, initialMint);
        }
    }

    /**
     * @dev Pause all token transfers (emergency stop)
     * @notice Only accounts with PAUSER_ROLE can call this
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause token transfers
     * @notice Only accounts with PAUSER_ROLE can call this
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Mint tokens to specified address
     * @param to Address to mint tokens to
     * @param amount Amount to mint in wei
     * @notice Only accounts with MINTER_ROLE can call this
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Gas-optimized batch airdrop function
     * @param to Array of recipient addresses
     * @param amounts Array of amounts to mint (must match to.length)
     * @notice Only accounts with MINTER_ROLE can call this
     * @notice Pre-validates total against cap to prevent failed transactions
     */
    function airdrop(address[] calldata to, uint256[] calldata amounts) 
        external 
        onlyRole(MINTER_ROLE) 
    {
        if (to.length != amounts.length) revert ArrayLengthMismatch();

        uint256 len = to.length;
        uint256 sum;

        // Calculate total amount to mint
        for (uint256 i = 0; i < len; ) {
            sum += amounts[i];
            unchecked { ++i; }
        }

        // Check cap before any minting
        if (totalSupply() + sum > cap()) revert CapExceeded();

        // Mint to all recipients
        for (uint256 j = 0; j < len; ) {
            _mint(to[j], amounts[j]);
            unchecked { ++j; }
        }
    }

    /**
     * @dev Override required by Solidity for multiple inheritance
     * @notice OZ v5 combines hooks via _update
     */
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Capped)
    {
        super._update(from, to, value);
    }
}