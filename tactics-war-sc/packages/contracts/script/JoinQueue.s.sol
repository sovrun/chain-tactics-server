// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { Base_Script } from "./Base.s.sol";
import { TTW_NAMESPACES, MATCH_SYSTEM } from "../src/common/constants.sol";

import { MatchSystem } from "../src/systems/MatchSystem.sol";

contract JoinQueueScript is Base_Script {
    function _run(IWorld world) public override broadcastPlayer {
        bytes32 boardEntity = bytes32(uint256(1));
        bytes32 gameModeEntity = bytes32(uint256(3));

        world.call(
            matchSystemId(),
            abi.encodeCall(MatchSystem.joinQueue, (boardEntity, gameModeEntity))
        );
    }
}
