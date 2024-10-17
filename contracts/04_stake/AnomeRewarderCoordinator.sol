// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/token/ERC20/IERC20.sol";
import "../00_lib/zeppelin/token/ERC20/utils/SafeERC20.sol";

import "../01_base/DefaultAccessControl.sol";
import "../01_base/interface/IReferral.sol";
import "../01_base/interface/IvNome.sol";
import "../01_base/interface/IoNFT.sol";
import "../01_base/interface/IAnomeRewarder.sol";

contract AnomeRewarderCoordinator is DefaultAccessControl {
    using SafeERC20 for IERC20;
    uint256 public constant DIVISOR = 1000;

    event OnBattleRewawrd(address indexed account, uint256 reward);
    event OnReferralRewawrd(address indexed account, uint256 reward);

    struct AccountStatistic {
        uint256[] oNFTs;
        uint256 currentONFT;
        mapping(uint256 => uint256) vNomeByNFTId;
    }

    IvNome public vNome;
    IoNFT public oNFT;
    IReferral public referral;
    IAnomeRewarder public rewarder;

    mapping(address => AccountStatistic) internal _accountStatistics;

    constructor(address _admin, address _vNome, address _oNFT, address _referral, address _rewarder) {
        _setupRoles(_admin, msg.sender);

        vNome = IvNome(_vNome);
        oNFT = IoNFT(_oNFT);
        referral = IReferral(_referral);
        rewarder = IAnomeRewarder(_rewarder);
    }

    function onStake(
        address to,
        uint256 _anomeId,
        uint256 _stakeDays,
        uint256 _vAmount,
        uint256 _boost,
        uint256 _loyalty
    ) external onlyCaller {
        rewarder.update(to);

        // 为用户发放oNFT, vNome, 创建邀请码
        vNome.mint(to, _vAmount);
        oNFT.mint(to, _anomeId, _stakeDays, _boost, _loyalty);

        // 记录用户持有的oNFT
        uint256 oNFTId = oNFT.tokenIdByAnomeId(_anomeId);
        _accountStatistics[to].oNFTs.push(oNFTId);
        _accountStatistics[to].vNomeByNFTId[oNFTId] += _vAmount;

        // 如果没有生效中的oNFT, 则设置
        if (_accountStatistics[to].currentONFT == 0) {
            _accountStatistics[to].currentONFT = oNFTId;
        }
    }

    function onUnstake(address account, uint256 _anomeId, bool isForce) external onlyCaller {
        rewarder.update(account);

        // // 销毁oNFT
        uint256 burnId = oNFT.tokenIdByAnomeId(_anomeId);
        oNFT.burn(burnId);

        // 销毁此oNFT得到的vNome
        AccountStatistic storage statistic = _accountStatistics[account];
        if (isForce) {
            uint256 vNomeBurnAmount = statistic.vNomeByNFTId[burnId];
            if (vNomeBurnAmount > vNome.balanceOf(account)) {
                vNome.burn(account, vNome.balanceOf(account));
                vNomeBurnAmount = vNome.balanceOf(account);
            } else {
                vNome.burn(account, vNomeBurnAmount);
            }
            statistic.vNomeByNFTId[burnId] -= vNomeBurnAmount;
        }

        // 找到最早的oNFT(当前生效中的oNFT)
        uint256 currentONFTIndex = type(uint256).max;

        for (uint i = 0; i < statistic.oNFTs.length; i++) {
            if (statistic.oNFTs[i] != 0) {
                currentONFTIndex = i;
                break;
            }
        }

        // 清除当前生效中的oNFT记录, 并移动到下一位
        if (currentONFTIndex != type(uint256).max) {
            delete statistic.oNFTs[currentONFTIndex];

            if ((currentONFTIndex + 1) < statistic.oNFTs.length) {
                statistic.currentONFT = statistic.oNFTs[currentONFTIndex + 1];
            } else {
                statistic.currentONFT = 0;
            }
        }
    }

    function onBattle(address winner, address loser, uint256 amount) external onlyCaller {
        address winnerSuperior = referral.accountSuperior(winner);
        address loserSuperior = referral.accountSuperior(loser);

        _sendvNome(winner, (amount * 10) / 100, false);
        _sendvNome(loser, (amount * 70) / 100, false);
        _sendvNome(winnerSuperior, (amount * 10) / 100, true);
        _sendvNome(loserSuperior, (amount * 10) / 100, true);
    }

    function _sendvNome(address account, uint256 amount, bool isReferral) internal {
        rewarder.update(account);

        if (account == address(0)) {
            return;
        }

        uint256 boostAmount = _vNomeWithBoost(account, amount);
        if (isReferral) {
            emit OnReferralRewawrd(account, boostAmount);
        } else {
            emit OnBattleRewawrd(account, boostAmount);
        }
    }

    function _vNomeWithBoost(address account, uint256 amount) internal returns (uint256) {
        uint256 current = _accountStatistics[account].currentONFT;
        uint256 boostReward = 0;
        if (current == 0) {
            boostReward = amount;
        } else {
            boostReward = (amount * oNFT.metadata(current).boost) / DIVISOR;
            _accountStatistics[account].vNomeByNFTId[current] += (boostReward - amount);
        }
        vNome.mint(account, boostReward);

        return boostReward;
    }

    function accountCurrentBoost(
        address account
    ) external view returns (uint256 boost, uint256 loyalty, uint256 stakeDays) {
        uint256 current = _accountStatistics[account].currentONFT;
        if (current == 0) {
            boost = 0;
            loyalty = 0;
            stakeDays = 0;
        } else {
            IoNFT.Metadata memory metadata = oNFT.metadata(current);
            boost = metadata.boost;
            loyalty = metadata.loyalty;
            stakeDays = metadata.stakeDays;
        }
    }

    function accountONFTs(address account) external view returns (uint256[] memory result) {
        uint256[] memory oNFTs = _accountStatistics[account].oNFTs;
        result = new uint256[](oNFTs.length);

        for (uint i = 0; i < oNFTs.length; i++) {
            result[i] = oNFTs[i];
        }
    }

    function accountCurrentONFT(address account) external view returns (uint256) {
        return _accountStatistics[account].currentONFT;
    }

    function accountVNomeByNFT(address account, uint256 nft) external view returns (uint256) {
        return _accountStatistics[account].vNomeByNFTId[nft];
    }

    function setDepends(address _vNome, address _oNFT, address _referral, address _rewarder) external onlyConfigurator {
        vNome = IvNome(_vNome);
        oNFT = IoNFT(_oNFT);
        referral = IReferral(_referral);
        rewarder = IAnomeRewarder(_rewarder);
    }
}
