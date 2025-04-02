// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { SystemIds } from "../src/libraries/SystemIds.sol";
import { TTW_NAMESPACES, MATCH_SYSTEM } from "../src/common/constants.sol";

abstract contract Base_Script is Script {
    using SystemIds for bytes14;

    uint256 internal signerPk;
    uint256 internal playerPk;

    constructor() {
        signerPk = vm.envUint("PRIVATE_KEY");
        playerPk = vm.envUint("PLAYER_KEY");
    }

    modifier broadcast() {
        vm.startBroadcast(signerPk);
        _;
        vm.stopBroadcast();
    }

    modifier broadcastPlayer() {
        vm.startBroadcast(playerPk);
        _;
        vm.stopBroadcast();
    }

    function run(address worldAddress) public virtual {
        IWorld world = IWorld(worldAddress);
        _run(world);
    }

    function _run(IWorld world) public virtual;

    function matchSystemId() internal pure returns (ResourceId) {
        return TTW_NAMESPACES.matchSystem();
    }
}
