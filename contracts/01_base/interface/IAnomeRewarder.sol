// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAnomeRewarder {
    function DIVISOR() external view returns (uint256);

    event RewardPaid(address indexed account, uint256 amount);
    event OnBattleRewawrd(address indexed account, uint256 reward);
    event OnReferralRewawrd(address indexed account, uint256 reward);

    struct Reward {
        uint256 issued;
        uint256 perTokenStored;
        uint256 latestUpdateTime;
    }

    struct Account {
        uint256 perTokenPaid;
        uint256 pendingRewards;
    }

    function usdt() external view returns (address);

    function vNome() external view returns (address);

    function claimEarnings() external;

    function update(address account) external;

    function totalRewards() external view returns (uint256);

    function perTokenRewards() external view returns (uint256);

    function accountEarnings(address account) external view returns (uint256);

    function accountTotalEarnings(address account) external view returns (uint256);

    function rewardInfo() external view returns (Reward memory);

    function accountInfo(address account) external view returns (Account memory);

    function transfer(address _token, uint256 _amount) external;

    function setTokens(address _usdt, address _vNome) external;

    function setReward(Reward memory _rewardInfo) external;

    function setAccount(address _address, Account memory _account) external;
}
