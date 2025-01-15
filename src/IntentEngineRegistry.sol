// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract IntentEngineRegistry {
    mapping(string => address) internal uniswapV2Pairs;

    //weth 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    //usdc 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    // 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc
    //dai 0x6B175474E89094C44Da98b954EedeAC495271d0F

    constructor(){
        uniswapV2Pairs["usdc/weth"] = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc; //usdc token0 to weth token1
        uniswapV2Pairs["dai/weth"] = 0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11; //dai token0 to weth token1
    }

}
