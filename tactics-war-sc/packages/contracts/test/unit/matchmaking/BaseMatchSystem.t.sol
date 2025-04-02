// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../Base.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES, MATCH_SYSTEM } from "src/common/constants.sol";

import { PlayerStatusTypes } from "src/common/types.sol";

import { MatchConfig, MatchConfigData } from "src/codegen/tables/MatchConfig.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";

import { MatchSystem } from "src/systems/MatchSystem.sol";
import { IMatchSystem } from "src/systems/interfaces/IMatchSystem.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { SystemBuilder, WorldSystemBuilder } from "../SystemBuilder.t.sol";
import { LibFunctions } from "./LibFunctions.t.sol";

contract BaseMatchSystem_Test is Base_Test {
    using LibFunctions for WorldSystemBuilder;
    using SystemBuilder for IWorld;

    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function _joinQueue(bytes32 boardEntity, bytes32 modeEntity) internal {
        world.matchSystem().joinQueue(boardEntity, modeEntity);
    }

    function _setPlayerReadyAndStart(bytes32 matchEntity) internal {
        world.matchSystem().setPlayerReadyAndStart(matchEntity);
    }

    function _leave() internal {
        world.matchSystem().leave();
    }

    function _claimVictory(bytes32 matchEntity) internal {
        world.matchSystem().claimVictory(matchEntity);
    }
}
