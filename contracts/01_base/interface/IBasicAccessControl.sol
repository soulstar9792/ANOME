// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IBasicAccessControl {
    function ROLE_ADMIN() external view returns (bytes32);

    function ROLE_CONFIG() external view returns (bytes32);

    function ROLE_CALLER() external view returns (bytes32);

    function adminAccount() external view returns (address);

    function configAccount() external view returns (address);

    function grantAdmin(address account) external;

    function grantConfigurator(address account) external;

    function grantCaller(address account) external;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
