// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {IntentEngine} from "../src/IntentEngineTrade.sol";
import {IUniswap} from "../src/IUniswap.sol";
import {IERC20} from "../src/IERC20.sol";

contract TradeTest is Test {
    // Contracts
    IntentEngine intentEngine;
    address constant weth_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH on ETH Mainnet

    IUniswap public uniswapRouter;

    // Accounts
    address user = address(1);

    // Fork IDs
    uint256 public ethereumMainnetForkId;

    function setUp() public {
        // Create Forks
        ethereumMainnetForkId = vm.createFork(
            "https://eth-mainnet.g.alchemy.com/v2/KywLaq2zlVzePOhip0BY3U8ztfHkYDmo"
        );

        // Deploy Intent Engine
        vm.selectFork(ethereumMainnetForkId);
        intentEngine = new IntentEngine();
        uniswapRouter = IUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        console.log("Intent Engine address: ", address(intentEngine));
        console.log("Setup done");
    }

    function testTrade() public {
        vm.selectFork(ethereumMainnetForkId);

        deal(weth_address, user, 10 * 1e18); //10 WETH given to user

        // Fetching user balance
        uint256 userBalance = IERC20(weth_address).balanceOf(user); // WETH BALANCE
        console.log("User balance: ", userBalance); // 10 WETH is coming

        // Fetching intent values

        uint256 amount;
        string memory pair;
        string memory protocol;
        (pair, amount, protocol) = intentEngine.returnIntentValues(
            "weth/dai 1 uniswap"
        );
        console.log("Pair: ", pair);
        console.log("Amount: ", amount / 1e18);
        console.log("Protocol: ", protocol);

        // Fetching path for pair
        address[] memory pathArray = new address[](2);
        pathArray = intentEngine.getPathForPair(pair);
        console.log("Path Array 1st : ", pathArray[0]); // WETH
        console.log("Path Array 2nd : ", pathArray[1]); //  DAI

        vm.prank(user); // Execute the transaction as the user

        // Swapping on Uniswap
        require(
            IERC20(pathArray[0]).approve(address(uniswapRouter), amount),
            "approve failed."
        );
        console.log("Approved Uniswap to spend ", amount);

        // intentEngine.commandToTrade("weth/dai 1 uniswap");

        vm.stopPrank();

        uint256 allowance = IERC20(pathArray[0]).allowance(
            user,
            address(uniswapRouter)
        );
        console.log("Allowance given to Uniswap:", allowance);
        require(amount == allowance, "Allowance not set");
        uint256[] memory amountsOut = IUniswap(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ).getAmountsOut(amount, pathArray);

        console.log(
            "Expected DAI output: ",
            amountsOut[1] / 1e18,
            "address of coin output",
            pathArray[1]
        );

        // ---------------------- DAI TO WETH nhi hora but Weth to DAI hora ----------------------

        vm.prank(user);
        IERC20(pathArray[0]).approve(address(intentEngine), amount);
        vm.prank(user);

        intentEngine.commandToTrade("weth/dai 1 uniswap");
        console.log("Swapped on Uniswap");

        uint256 userBalanceRemainsAfterTradeFirst = IERC20(pathArray[0])
            .balanceOf(address(user));
        console.log(
            "User balance remains after trade: ",
            userBalanceRemainsAfterTradeFirst / 1e18
        );
    }
}
