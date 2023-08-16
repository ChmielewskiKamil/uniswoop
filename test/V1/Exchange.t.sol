// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Token} from "src/V1/Token.sol";
import {Exchange} from "src/V1/Exchange.sol";

contract ExchangeTest is Test {
    // Protocol Actors
    address public ADMIN;
    address public ALICE;

    Token public token;
    Exchange public exchange;

    function setUp() public {
        ADMIN = makeAddr("ADMIN");
        ALICE = makeAddr("ALICE");

        vm.startPrank(ADMIN);
        token = new Token("Uniswooop", "USWP", 100_000e18);
        exchange = new Exchange(address(token));

        token.transfer(ALICE, 10_000e18);
        vm.stopPrank();
    }

    // Initial supply - amount sent to Alice
    function test_AdminOwnsInitialSupply() public {
        assertEq(token.balanceOf(ADMIN), 90_000e18);
        assertEq(token.balanceOf(address(exchange)), 0);
    }

    function test_NaiveAddLiquidity() public {
        uint256 exchangeTokenBalanceBefore = token.balanceOf(address(exchange));
        uint256 aliceTokenBalanceBefore = token.balanceOf(address(ALICE));

        vm.startPrank(ALICE);
        exchange.addLiquidity(1_000e18);
        vm.stopPrank();

        uint256 exchangeTokenBalanceAfter = token.balanceOf(address(exchange));
        uint256 aliceTokenBalanceAfter = token.balanceOf(address(ALICE));

        assertEq(exchangeTokenBalanceAfter, exchangeTokenBalanceBefore + 1_000e18);
        assertEq(aliceTokenBalanceAfter, aliceTokenBalanceBefore - 1_000e18);
    }
}
