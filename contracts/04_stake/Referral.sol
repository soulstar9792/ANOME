// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/token/ERC20/IERC20.sol";
import "../00_lib/zeppelin/token/ERC20/utils/SafeERC20.sol";
import "../00_lib/zeppelin/utils/Strings.sol";
import "../01_base/DefaultAccessControl.sol";

contract Referral is DefaultAccessControl {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    // ================== Struct ==================

    struct Junior {
        address account;
        uint256 timestamp;
    }

    error NotSupport();
    error AlreadyCreated();
    error AlreadyBinded();
    error InvalidAccount(address account);
    error InvalidSuperior(address account);
    error CodeGenerationError(uint256 code);

    event CodeSet(address indexed caller, address indexed account, uint256 indexed code);
    event RelationBinded(address indexed caller, address indexed account, address indexed superior);

    // ================== Vars ==================

    mapping(uint256 => bool) private _codeExists;

    IERC20 public usdt;
    uint256 public codePrice;
    mapping(address => uint256) public codeByAccount;
    mapping(uint256 => address) public accountByCode;

    mapping(address => address) private _accountSuperior;
    mapping(address => Junior[]) private _accountJuniors;

    constructor(address _admin, address _usdt, uint256 _codePrice) {
        _setupRoles(_admin, msg.sender);
        usdt = IERC20(_usdt);
        codePrice = _codePrice;
    }

    // ================== Data access ==================

    function _genCode(address account) private returns (uint256) {
        account;

        uint256 newCode = block.timestamp;
        for (uint i = 0; i < 999; i++) {
            if (_codeExists[newCode]) {
                newCode = newCode + 1;
            } else {
                break;
            }
        }

        _codeExists[newCode] = true;

        return newCode;
    }

    function _setCode(address account, uint256 code) internal {
        if (accountByCode[code] != address(0)) revert CodeGenerationError(code);

        codeByAccount[account] = code;
        accountByCode[code] = account;

        emit CodeSet(msg.sender, account, code);
    }

    function _recreateCode(address account) internal {
        uint256 code = _genCode(account);
        _setCode(account, code);
    }

    function _removeCode(address account, bool isRemoveRelation) internal {
        uint256 oldCode = codeByAccount[account];
        delete codeByAccount[account];
        delete accountByCode[oldCode];

        if (isRemoveRelation) {
            _removeSuperior(account);
            _removeAllJuniors(account);
        }
    }

    function _bindSuperior(address account, address superior) internal {
        if (superior == address(0)) revert InvalidAccount(superior);
        if (superior == account) revert InvalidSuperior(superior);

        _accountSuperior[account] = superior;
        _accountJuniors[superior].push(Junior({account: account, timestamp: block.timestamp}));

        emit RelationBinded(msg.sender, account, superior);
    }

    function _changeSuperior(address account, address newSuperior) internal {
        address oldSuperior = _accountSuperior[account];
        _removeJunior(oldSuperior, account);
        _bindSuperior(account, newSuperior);
    }

    function _removeSuperior(address account) internal {
        if (account == address(0)) {
            return;
        }

        delete _accountSuperior[account];
    }

    function _removeJunior(address account, address junior) internal {
        if (account == address(0)) {
            return;
        }

        if (junior == address(0)) {
            return;
        }

        Junior[] storage juniors = _accountJuniors[account];
        for (uint i = 0; i < juniors.length; i++) {
            if (juniors[i].account == account) {
                delete juniors[i];
            }
        }

        _removeSuperior(junior);
    }

    function _removeAllJuniors(address account) internal {
        if (account == address(0)) {
            return;
        }

        Junior[] memory juniors = _accountJuniors[account];
        for (uint i = 0; i < juniors.length; i++) {
            _removeSuperior(juniors[i].account);
        }

        delete _accountJuniors[account];
    }

    // ================== Query ==================

    function accountSuperior(address account) external view returns (address) {
        return _accountSuperior[account];
    }

    // 返回的数组中可能会有address(0), 需要额外判断
    function accountJuniors(address account) external view returns (Junior[] memory) {
        Junior[] memory _juniors = new Junior[](_accountJuniors[account].length);
        for (uint256 i = 0; i < _accountJuniors[account].length; i++) {
            _juniors[i] = _accountJuniors[account][i];
        }
        return _juniors;
    }

    // 不包含自身
    function superiorChain(address account, uint256 length) external view returns (address[] memory) {
        address[] memory _superiors = new address[](length);
        for (uint256 i = 0; i < _superiors.length; i++) {
            address curAccount;

            if (i == 0) {
                curAccount = account;
            } else {
                curAccount = _superiors[i - 1];
            }

            address curSuperior = _accountSuperior[curAccount];
            if (curSuperior == address(0)) {
                break;
            } else {
                _superiors[i] = curSuperior;
            }
        }
        return _superiors;
    }

    // ================== Account ==================

    function createCode() external {
        usdt.safeTransferFrom(msg.sender, address(this), codePrice);

        address account = msg.sender;
        if (codeByAccount[account] != 0) revert AlreadyCreated();

        _recreateCode(account);
    }

    function bindSuperior(uint256 superiorCode) external {
        address account = msg.sender;
        if (_accountSuperior[account] != address(0)) revert AlreadyBinded();

        address superiorAddress = accountByCode[superiorCode];
        _bindSuperior(account, superiorAddress);
    }

    // ================== Admin ==================

    function setCodePrice(uint256 _codePrice) external onlyConfigurator {
        codePrice = _codePrice;
    }

    function adminCreateCode(address account) external onlyCaller {
        if (codeByAccount[account] != 0) revert AlreadyCreated();
        _recreateCode(account);
    }

    function adminRecreateCode(address account) external onlyCaller {
        _recreateCode(account);
    }

    function adminSetCode(address account, uint256 code) external onlyCaller {
        _setCode(account, code);
    }

    function adminRemoveCode(address account, bool isRemoveRelation) external onlyCaller {
        _removeCode(account, isRemoveRelation);
    }

    function adminBindSuperior(address account, address superior) external onlyCaller {
        if (_accountSuperior[account] != address(0)) revert AlreadyBinded();
        _bindSuperior(account, superior);
    }

    function adminSetRelation(address account, address superior) external onlyCaller {
        _changeSuperior(account, superior);
    }

    function adminRemoveRelation(address account) external onlyCaller {
        _removeSuperior(account);
        _removeAllJuniors(account);
    }
}
