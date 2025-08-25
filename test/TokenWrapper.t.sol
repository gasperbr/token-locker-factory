// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {TokenWrapper} from "../src/TokenWrapper.sol";
import {TokenWrapperFactory} from "../src/TokenWrapperFactory.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {DateTimeLib} from "solady/utils/DateTimeLib.sol";

contract MockERC20 is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TokenWrapperTest is Test {
    TokenWrapper public wrapper;
    TokenWrapperFactory public factory;
    MockERC20 public underlying;

    uint256 public august19Of2025 = 1755616480;
    address public user = makeAddr("user");

    function setUp() public {
        underlying = new MockERC20("Ekubo Protocol", "EKUBO", 18);
        underlying.mint(user, 100e18);
        factory = new TokenWrapperFactory();
        wrapper = factory.deployWrapper(underlying, "g", august19Of2025);
        vm.prank(user);
        underlying.approve(address(wrapper), type(uint256).max);
    }

    function testDeployWrapperGas() public {
        factory.deployWrapper(underlying, "g", august19Of2025);
        vm.snapshotGasLastCall("deployWrapper");
    }

    function testTokenInfo() public view {
        assertEq(wrapper.symbol(), "gEKUBO 25Q3");
        assertEq(wrapper.name(), "Ekubo Protocol Aug/19/2025");
        assertEq(wrapper.unlockTime(), august19Of2025);
    }

    function testWrap(uint256 wrapAmount) public {
        vm.startPrank(user);
        if (wrapAmount > underlying.balanceOf(user)) {
            vm.expectRevert();
            wrapper.wrap(wrapAmount);
            return;
        }
        wrapper.wrap(wrapAmount);
        assertEq(wrapper.balanceOf(user), wrapAmount, "Didn't mint wrapper");
        assertEq(underlying.balanceOf(address(wrapper)), wrapAmount, "Didn't transfer underlying");
    }

    function testUnwrapTo(address recipient, uint256 wrapAmount, uint256 unwrapAmount, uint256 time) public {
        wrapAmount = bound(wrapAmount, 0, underlying.balanceOf(user));

        vm.startPrank(user);
        wrapper.wrap(wrapAmount);
        uint256 oldBalance = underlying.balanceOf(recipient);

        vm.warp(time);
        if (time < august19Of2025 || unwrapAmount > wrapAmount) {
            vm.expectRevert();
            wrapper.unwrap(unwrapAmount);
            return;
        }
        wrapper.unwrapTo(recipient, unwrapAmount);
        assertEq(wrapper.balanceOf(user), wrapAmount - unwrapAmount, "Didn't burn wrapper");
        assertEq(underlying.balanceOf(recipient), oldBalance + unwrapAmount, "Didn't transfer underlying");
    }
}
