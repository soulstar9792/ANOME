//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Strings} from "../00_lib/zeppelin/utils/Strings.sol";
import {ERC404Legacy} from "../00_lib/erc404/legacy/ERC404Legacy.sol";
import {IUniswapV2Router02} from "../00_lib/uniswap_v2/interfaces/IUniswapV2Router02.sol";

struct CardAttributes {
    uint256 top;
    uint256 bottom;
    uint256 left;
    uint256 right;
    uint256 index;
    uint256 level;
}

contract AnomeCard is ERC404Legacy {
    /* prettier-ignore */ bytes32        public  PAIR_HASH;
    /* prettier-ignore */ string         public  getFixedUri;
    /* prettier-ignore */ CardAttributes private _cardAttributes;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply_,
        string memory tokenUri_,
        address uniswapV2Router_,
        address uniswapV2TokenB_,
        bytes32 uniswapPairHash_,
        CardAttributes memory cardAttributes_
    ) ERC404Legacy(name_, symbol_, decimals_, supply_, msg.sender) {
        getFixedUri = tokenUri_;
        whitelist[msg.sender] = true;
        balanceOf[msg.sender] = supply_ * 10 ** decimals_;

        PAIR_HASH = uniswapPairHash_;
        IUniswapV2Router02 uniswapV2RouterContract = IUniswapV2Router02(uniswapV2Router_);
        address uniswapV2Pair = _getUniswapV2Pair(uniswapV2RouterContract.factory(), uniswapV2TokenB_);
        whitelist[uniswapV2Router_] = true;
        whitelist[uniswapV2Pair] = true;

        _cardAttributes = cardAttributes_;
    }

    function _getUniswapV2Pair(address uniswapV2Factory_, address tokenB_) private view returns (address) {
        address thisAddress = address(this);

        (address token0, address token1) = thisAddress < tokenB_ ? (thisAddress, tokenB_) : (tokenB_, thisAddress);

        // Uniswap ETH 96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f
        // Pancake BSC a5934690703a592a07e841ca29d5e5c79b5e22ed4749057bb216dc31100be1c0
        // Pancake OpBNB 57224589c67f3f30a6b0d7a1b54cf3153ab84563bc609ef41dfb34f8b2974d2d
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                uniswapV2Factory_,
                                keccak256(abi.encodePacked(token0, token1)),
                                PAIR_HASH
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        id;
        return getFixedUri;
    }

    function getUnit() public view returns (uint256) {
        return _getUnit();
    }

    function setCardAttributes(CardAttributes memory cardAttributes_) external {
        _cardAttributes = cardAttributes_;
    }

    function getCardAttributes() public view returns (CardAttributes memory) {
        return _cardAttributes;
    }
}
