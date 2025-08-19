// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Script, console} from "forge-std/Script.sol";
import {TokenWrapperFactory} from "../src/TokenWrapperFactory.sol";
import {TokenWrapper} from "../src/TokenWrapper.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

contract DeployScript is Script {
    TokenWrapperFactory public factory;
    TokenWrapper public gEKUBOWrapper;
    
    // EKUBO token
    address constant EKUBO_TOKEN = 0x04C46E830Bb56ce22735d5d8Fc9CB90309317d0f;
    
    // March 31st, 2026 timestamp
    uint256 constant MAR_31_2026 = 1774915200;

    function run() public {
        vm.startBroadcast();

        // Deploy the factory
        factory = new TokenWrapperFactory();
        console.log("TokenWrapperFactory deployed at:", address(factory));

        // Create gEKUBO Mar31 wrapper
        gEKUBOWrapper = factory.deployWrapper(
            ERC20(EKUBO_TOKEN),
            "g",
            MAR_31_2026
        );
        
        console.log("gEKUBO 26Q1 wrapper deployed at:", address(gEKUBOWrapper));
        console.log("Wrapper name:", gEKUBOWrapper.name());
        console.log("Wrapper symbol:", gEKUBOWrapper.symbol());
        console.log("Unlock time:", gEKUBOWrapper.unlockTime());

        vm.stopBroadcast();
    }
}