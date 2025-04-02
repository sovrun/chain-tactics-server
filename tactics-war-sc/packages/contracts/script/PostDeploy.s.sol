// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { BoardConfig } from "../src/codegen/tables/BoardConfig.sol";

// import { GameMode } from "../src/codegen/tables/GameMode.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        // Specify a store so that you can use tables directly in PostDeploy
        StoreSwitch.setStoreAddress(worldAddress);

        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        // =========================================
        // Create Board Config
        // =========================================
        bytes32 boardEntity = bytes32(uint256(1));
        uint16 rows = 9;
        uint16 columns = 9;

        BoardConfig.set(boardEntity, rows, columns);

        // =========================================
        // Create Game Mode
        // =========================================
        // GameMode.set(1, 1, 1, 1);

        vm.stopBroadcast();
    }
}
