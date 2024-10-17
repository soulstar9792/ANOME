// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AnomeCard} from "./AnomeCard.sol";
import {IERC165} from "../00_lib/zeppelin/interfaces/IERC165.sol";
import {ERC721Receiver} from "../00_lib/erc404/legacy/ERC404Legacy.sol";

import {IERC20} from "../00_lib/zeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "../00_lib/zeppelin/token/ERC20/utils/SafeERC20.sol";

contract CardPool is IERC165, ERC721Receiver {
    using SafeERC20 for IERC20;

    address private constant HOLE = 0x000000000000000000000000000000000000dEaD;
    uint256 private constant DIVIDEND = 1000;

    error OnlyFactory();
    error InvalidReceiver();

    error InvalidAmount();
    error InvalidUsdtBalance();
    error SoldOut();

    error InvalidPrice();
    error InvalidSupply();
    error InvalidCirculation();

    /* prettier-ignore */ address   public factory;
    /* prettier-ignore */ IERC20    public usdt;
    /* prettier-ignore */ AnomeCard public card;
    /* prettier-ignore */ uint256   public reserveUsdt;
    /* prettier-ignore */ uint256   public reserveCard = 1;

    constructor() {
        factory = msg.sender;
    }

    function initialize(address usdtAddress_, address tokenAddress_, uint256 reserveUsdt_) external {
        if (msg.sender != factory) revert OnlyFactory();

        usdt = IERC20(usdtAddress_);
        card = AnomeCard(tokenAddress_);
        reserveUsdt = reserveUsdt_;
    }

    function buy(uint256 count) external {
        (, uint256 stock, , ) = getTokenCirculationInfo();

        if (count == 0) revert InvalidAmount();
        if (count > stock) revert SoldOut();

        uint256 price = currentPrice() * count;
        usdt.safeTransferFrom(msg.sender, address(this), price);

        card.transfer(msg.sender, count * card.getUnit());
    }

    function sell(uint256 count) external {
        if (count == 0) revert InvalidAmount();

        uint256 price = currentPrice() * count;
        card.safeTransferFrom(msg.sender, address(this), count * card.getUnit(), "");
        usdt.safeTransfer(msg.sender, price);
    }

    function onDestroyed(uint256 count, address[] memory receivers, uint256[] memory ratios) external {
        if (count == 0) revert InvalidAmount();
        if (msg.sender != factory) revert OnlyFactory();
        if (receivers.length != ratios.length) revert InvalidReceiver();

        // 因为Factory会直接把404代币转过来, 所以不需要再次滑扣
        uint256 price = currentPrice() * count;
        for (uint i = 0; i < receivers.length; i++) {
            usdt.safeTransfer(receivers[i], (price * ratios[i]) / DIVIDEND);
        }
    }

    function currentPrice() public view returns (uint256 price) {
        uint256 usdtBalance = usdt.balanceOf(address(this)) + reserveUsdt;
        if (usdtBalance == 0) revert InvalidUsdtBalance();

        (uint256 supply, uint256 stock, uint256 destruction, uint256 circulation) = getTokenCirculationInfo();
        if ((stock + destruction) > supply) revert InvalidSupply();
        if (circulation == 0) revert InvalidCirculation();

        price = usdtBalance / circulation;
        if (price == 0) revert InvalidPrice();

        return price;
    }

    /**
     * 此方法返回的所有量都是NFT个数, 已经去除单位
     * @return supply 供应量
     * @return stock 库存量
     * @return destruction 销毁量
     * @return circulation 流通量
     */
    function getTokenCirculationInfo()
        public
        view
        returns (uint256 supply, uint256 stock, uint256 destruction, uint256 circulation)
    {
        supply = card.totalSupply() / card.getUnit();
        stock = card.balanceOf(address(this)) / card.getUnit() - reserveCard;
        destruction = card.balanceOf(HOLE) / card.getUnit();

        if ((stock + destruction) <= supply) {
            circulation = supply - (stock + destruction);
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
