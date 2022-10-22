// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RoleControl is AccessControl {
    bytes32 public constant FEE_PAYER_ROLE = keccak256("FEE_PAYER_ROLE");

    constructor(address root) {
        _setupRole(DEFAULT_ADMIN_ROLE, root);
        _setupRole(FEE_PAYER_ROLE, root);
        _setRoleAdmin(FEE_PAYER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function isFeePayer(address account) public virtual view returns(bool){
        return hasRole(FEE_PAYER_ROLE, account);
    }

    modifier onlyFeePayer() {
        require(isFeePayer(msg.sender), "Restricted to fee payers");
        _;
    }

    function  isAdmin(address account) public virtual view returns(bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    modifier  onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted to admin");
        _;
    }

    function addFeePayer(address account) public virtual onlyAdmin {
        grantRole(FEE_PAYER_ROLE, account);
    }

    function removeFeePayer(address account) public virtual onlyAdmin {
        revokeRole(FEE_PAYER_ROLE, account);
    }

    function addAdmin(address account) public virtual onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function removeAdmin(address account) public virtual onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, account);
    }
}