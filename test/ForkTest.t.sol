// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {TokenWrapper} from "../src/TokenWrapper.sol";
import {TokenWrapperFactory} from "../src/TokenWrapperFactory.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

contract ForkTest is Test {
    ERC20 ekubo = ERC20(0x04C46E830Bb56ce22735d5d8Fc9CB90309317d0f);
    TokenWrapper wrapper;

    uint256 public constant blockNumber = 23226976;
    uint256 public constant unlockTime = 1772514000; // 2026-03-03T05:00:00.000Z

    address user = makeAddr("user");

    function setUp() public {
        vm.createSelectFork("https://eth.llamarpc.com", blockNumber);

        // Create the wrapper
        TokenWrapperFactory factory = new TokenWrapperFactory();
        wrapper = factory.deployWrapper(ekubo, unlockTime);

        // Give user some EKUBO tokens for testing
        deal(address(ekubo), user, 100e18);

        // Approve the wrapper
        vm.prank(user);
        ekubo.approve(address(wrapper), type(uint256).max);
    }

    function testWrapperInfo() public view {
        assertEq(wrapper.symbol(), "gEKUBO-26Q1");
        assertEq(wrapper.name(), "Ekubo Protocol Mar/3/2026");
        assertEq(wrapper.unlockTime(), unlockTime);
    }

    function testWrapUnwrap() public {
        uint256 wrapAmount = 75e18;
        uint256 initialBalance = ekubo.balanceOf(user);

        assertEq(initialBalance, 100e18);

        // Lock tokens
        vm.prank(user);
        wrapper.wrap(wrapAmount);

        assertEq(wrapper.balanceOf(user), 75e18);
        assertEq(ekubo.balanceOf(user), 25e18);

        // Try to unlock early (should fail)
        vm.expectRevert(TokenWrapper.TooEarly.selector);
        vm.prank(user);
        wrapper.unwrap(wrapAmount);

        // Fast forward to unlock time
        vm.warp(wrapper.unlockTime());

        // Unlock tokens
        vm.prank(user);
        wrapper.unwrap(wrapAmount);

        assertEq(ekubo.balanceOf(user), initialBalance);
        assertEq(wrapper.balanceOf(user), 0);
    }
}
