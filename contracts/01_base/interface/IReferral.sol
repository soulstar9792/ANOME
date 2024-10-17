// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IReferral {
    struct Junior {
        address account;
        uint256 timestamp;
    }

    function codeByAccount(address account) external view returns (uint256);

    function accountByCode(uint256 code) external view returns (address);

    function createCode() external;

    function bindSuperior(uint256 superiorCode) external;

    function accountSuperior(address account) external view returns (address);

    function accountJuniors(address account) external view returns (Junior[] memory);

    // 不包含自身
    // 返回的数组中可能会有address(0), 需要额外判断
    function superiorChain(address account, uint256 length) external view returns (address[] memory);

    function adminCreateCode(address account) external;

    function adminRecreateCode(address account) external;

    function adminSetCode(address account, uint256 code) external;

    function adminRemoveCode(address account, bool isRemoveRelation) external;

    function adminBindSuperior(address account, address superior) external;

    function adminSetRelation(address account, address superior) external;

    function adminRemoveRelation(address account) external;
}
