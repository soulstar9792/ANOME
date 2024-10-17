// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/token/ERC20/IERC20.sol";
import "../00_lib/zeppelin/token/ERC20/utils/SafeERC20.sol";

import "../01_base/DefaultAccessControl.sol";
import "../01_base/interface/IReferral.sol";
import "../01_base/interface/IvNome.sol";
import "../01_base/interface/IoNFT.sol";

contract AnomeRewarder is DefaultAccessControl {
    using SafeERC20 for IERC20;
    uint256 public constant DIVISOR = 1000;

    event RewardPaid(address indexed account, uint256 amount);
    event OnBattleRewawrd(address indexed account, uint256 reward);
    event OnReferralRewawrd(address indexed account, uint256 reward);

    struct Reward {
        uint256 issued;
        uint256 perTokenStored;
        uint256 latestUpdateds;
    }

    struct Account {
        uint256 perTokenPaid;
        uint256 pendingRewards;
    }

    IERC20 public usdt;
    IvNome public vNome;

    Reward internal _reward;
    mapping(address => Account) internal _accounts;

    constructor(address _admin, address _usdt, address _vNomeToken) {
        _setupRoles(_admin, msg.sender);

        usdt = IERC20(_usdt);
        vNome = IvNome(_vNomeToken);
    }

    function claimEarnings() external updateReward(msg.sender) {
        uint256 amount = _accounts[msg.sender].pendingRewards;

        if (amount > 0) {
            usdt.safeTransfer(msg.sender, amount);
            _accounts[msg.sender].pendingRewards = 0;
            _reward.issued = _reward.issued + amount;

            emit RewardPaid(msg.sender, amount);
        }
    }

    function update(address account) external updateReward(account) {}

    modifier updateReward(address account) {
        _reward.perTokenStored = perTokenRewards();
        _reward.latestUpdateds = totalRewards();
        if (account != address(0)) {
            _accounts[account].pendingRewards = accountEarnings(account);
            _accounts[account].perTokenPaid = _reward.perTokenStored;
        }
        _;
    }

    function totalRewards() public view returns (uint256) {
        return usdt.balanceOf(address(this)) + _reward.issued;
    }

    function perTokenRewards() public view returns (uint256) {
        if (vNome.totalSupply() == 0) {
            return _reward.perTokenStored;
        }

        uint256 _changed = totalRewards() - _reward.latestUpdateds;
        uint256 _newPerToken = (_changed * 1e18) / vNome.totalSupply();
        return _reward.perTokenStored + _newPerToken;
    }

    function accountEarnings(address account) public view returns (uint256) {
        uint256 _perTokenRemaing = perTokenRewards() - _accounts[account].perTokenPaid;
        uint256 _newRewards = (vNome.balanceOf(account) * _perTokenRemaing) / 1e18;
        return _newRewards + _accounts[account].pendingRewards;
    }

    function accountTotalEarnings(address account) external view returns (uint256) {
        return (perTokenRewards() * vNome.balanceOf(account)) / 1e18;
    }

    function rewardInfo() external view returns (Reward memory) {
        return _reward;
    }

    function accountInfo(address account) external view returns (Account memory) {
        return _accounts[account];
    }

    function transfer(address _token, uint256 _amount) external onlyAdmin {
        IERC20(_token).transfer(adminAccount, _amount);
    }

    function setTokens(address _usdt, address _vNome) external onlyConfigurator {
        usdt = IERC20(_usdt);
        vNome = IvNome(_vNome);
    }

    function setReward(Reward memory _rewardInfo) external onlyConfigurator {
        _reward = _rewardInfo;
    }

    function setAccount(address _address, Account memory _account) external onlyConfigurator {
        _accounts[_address] = _account;
    }
}
