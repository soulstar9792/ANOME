// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAnomeRewarderCoordinator {
    function DIVISOR() external view returns (uint256);

    event OnBattleRewawrd(address indexed account, uint256 reward);
    event OnReferralRewawrd(address indexed account, uint256 reward);

    struct AccountStatistic {
        uint256[] oNFTs;
        uint256 currentONFT;
        mapping(uint256 => uint256) vNomeByNFTId;
    }

    function vNome() external view returns (address);

    function oNFT() external view returns (address);

    function referral() external view returns (address);

    function onStake(
        address to,
        uint256 _anomeId,
        uint256 _stakeDays,
        uint256 _vAmount,
        uint256 _boost,
        uint256 _loyalty
    ) external;

    function onUnstake(address account, uint256 _anomeId, bool isForce) external;

    function onBattle(uint256 code) external;

    function accountCurrentBoost(
        address account
    ) external view returns (uint256 boost, uint256 loyalty, uint256 stakeDays);

    function accountONFTs(address account) external view returns (uint256[] memory result);

    function accountCurrentONFT(address account) external view returns (uint256);

    function accountVNomeByNFT(address account, uint256 nft) external view returns (uint256);

    function setDepends(address _vNome, address _oNFT, address _referral, address _rewarder) external;
}
