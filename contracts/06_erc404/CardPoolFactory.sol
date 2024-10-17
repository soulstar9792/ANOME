// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../00_lib/zeppelin/access/Ownable.sol";
import {IERC165} from "../00_lib/zeppelin/interfaces/IERC165.sol";
import {ERC721Receiver} from "../00_lib/erc404/legacy/ERC404Legacy.sol";

import {Create2} from "../00_lib/zeppelin/utils/Create2.sol";
import {AnomeCard, CardAttributes} from "./AnomeCard.sol";
import {CardPool} from "./CardPool.sol";

import {IERC20} from "../00_lib/zeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "../00_lib/zeppelin/token/ERC20/utils/SafeERC20.sol";

contract CardPoolFactory is Ownable, IERC165, ERC721Receiver {
    using SafeERC20 for IERC20;

    address private constant HOLE = 0x000000000000000000000000000000000000dEaD;
    uint256 private constant DIVIDEND = 1000;

    error InvalidBalance();
    error InvalidAmount();
    error InvalidTokenAddress();
    error TokenAlreadyExists();
    error IndexAlreadyExists();
    error InvalidReceiver();
    error InvalidRatio();

    struct Pool {
        string uri;
        address token;
        address pool;
        CardAttributes attrs;
    }

    /* prettier-ignore */ address public  usdt;
    /* prettier-ignore */ Pool[]  private allPools;

    /* prettier-ignore */ mapping(address => Pool)   public  getPoolByToken;
    /* prettier-ignore */ mapping(uint256 => Pool)   public  getPoolByIndex;
    /* prettier-ignore */ mapping(uint256 => Pool[]) private poolListOfLevel;

    /* prettier-ignore */ address[] public destoryReceivers;
    /* prettier-ignore */ uint256[] public destoryReceiverRatios;

    constructor(
        address _usdt,
        address[] memory _destoryReceivers,
        uint256[] memory _destoryReceiverRatios
    ) Ownable(msg.sender) {
        usdt = _usdt;
        setDestoryParams(_destoryReceivers, _destoryReceiverRatios);
        setDestoryParams(_destoryReceivers, _destoryReceiverRatios);
    }

    function createPool(
        address tokenAddr,
        uint256 initialPrice
    ) external onlyOwner returns (address) {
        AnomeCard token = AnomeCard(tokenAddr);
        CardAttributes memory cardAttr = token.getCardAttributes();

        if (getPoolByToken[tokenAddr].token != address(0)) revert TokenAlreadyExists();
        if (getPoolByIndex[cardAttr.index].token != address(0)) revert IndexAlreadyExists();

        address newPool = Create2.deploy(0, keccak256(abi.encodePacked(tokenAddr)), type(CardPool).creationCode);
        CardPool(newPool).initialize(usdt, tokenAddr, initialPrice);

        Pool memory poolInfo = Pool({
            uri: token.getFixedUri(),
            pool: newPool,
            token: tokenAddr,
            attrs: token.getCardAttributes()
        });

        allPools.push(poolInfo);
        getPoolByToken[tokenAddr] = poolInfo;
        getPoolByIndex[cardAttr.index] = poolInfo;
        poolListOfLevel[cardAttr.level].push(poolInfo);

        return newPool;
    }

    function destoryToken(address tokenAddr, uint256 count) external {
        if (tokenAddr == address(0)) revert InvalidTokenAddress();
        if (count == 0) revert InvalidAmount();

        address pool = getPoolByToken[tokenAddr].pool;
        AnomeCard card = AnomeCard(tokenAddr);
        card.safeTransferFrom(msg.sender, pool, count * card.getUnit(), "");
        CardPool(pool).onDestroyed(count, destoryReceivers, destoryReceiverRatios);
    }

    function getAllPools() external view returns (Pool[] memory pools) {
        Pool[] storage current = allPools;
        pools = new Pool[](current.length);
        for (uint i = 0; i < current.length; i++) {
            pools[i] = current[i];
        }
        return pools;
    }

    function getPoolListByLevel(uint256 level) external view returns (Pool[] memory pools) {
        Pool[] storage current = poolListOfLevel[level];
        pools = new Pool[](current.length);
        for (uint i = 0; i < current.length; i++) {
            pools[i] = current[i];
        }
        return pools;
    }

    function setDestoryParams(address[] memory receivers, uint256[] memory ratios) public onlyOwner {
        if (receivers.length != ratios.length) revert InvalidReceiver();

        uint256 destoryReceiversLength = destoryReceivers.length;
        for (uint i = 0; i < destoryReceiversLength; i++) {
            destoryReceivers.pop();
        }

        for (uint i = 0; i < receivers.length; i++) {
            destoryReceivers.push(receivers[i]);
        }

        uint256 destoryReceiverRatiosLength = destoryReceiverRatios.length;
        for (uint i = 0; i < destoryReceiverRatiosLength; i++) {
            destoryReceiverRatios.pop();
        }

        for (uint i = 0; i < ratios.length; i++) {
            destoryReceiverRatios.push(ratios[i]);
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        operator;
        from;
        tokenId;
        data;

        return ERC721Receiver.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(ERC721Receiver).interfaceId;
    }
}
