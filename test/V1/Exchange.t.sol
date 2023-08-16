// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Token} from "src/V1/Token.sol";
import {Exchange} from "src/V1/Exchange.sol";

contract ExchangeTest is Test {
    address public ADMIN;
    Token public token;
    Exchange public exchange;

    function setUp() public {
        ADMIN = makeAddr("ADMIN");

        vm.startPrank(ADMIN);
        token = new Token("Uniswooop", "USWP", 100_000e18);
        exchange = new Exchange(address(token));
        vm.stopPrank();
    }

    function test_AdminOwnsInitialSupply() public {
        assertEq(token.balanceOf(ADMIN), 100_000e18);
        assertEq(token.balanceOf(address(exchange)), 0);
    }
}
