// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract UniswapRegistry {
    // dai/weth means dai to weth
    // dai/weth => array[dai, weth]
    //string to array of address ki mapping banegi

    mapping(string => address[]) private uinswapPairsToPath;

    //weth 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    //usdc 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    // 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc
    //dai 0x6B175474E89094C44Da98b954EedeAC495271d0F

    constructor() {
        // Swap Dai to Weth
        uinswapPairsToPath["weth/dai"] = [
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            0x6B175474E89094C44Da98b954EedeAC495271d0F
        ];
        uinswapPairsToPath["weth/usdc"] = [
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        ];
    }

    // Getter Functions

    function getPathForPair(
        string memory pair
    ) public view returns (address[] memory) {
        return uinswapPairsToPath[pair];
    }
}
