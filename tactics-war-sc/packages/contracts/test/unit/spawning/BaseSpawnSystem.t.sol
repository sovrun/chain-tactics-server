// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../Base.t.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";
import { PositionData } from "src/codegen/tables/Position.sol";
import { SystemBuilder, WorldSystemBuilder } from "../SystemBuilder.t.sol";
import { LibFunctions } from "./LibFunctions.t.sol";

contract BaseSpawnSystem_Test is Base_Test {
    using LibFunctions for WorldSystemBuilder;
    using SystemBuilder for IWorld;

    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function _commitSpawn(bytes32 commitHash, bytes32 matchEntity) internal {
        world.spawnSystem().commitSpawn(commitHash, matchEntity);
    }

    function _revealSpawn(
        bytes32 matchEntity,
        PositionData[] memory coordinates,
        bytes32[] memory pieceEntities,
        bytes32 secret
    ) internal {
        world.spawnSystem().revealSpawn(
            matchEntity,
            coordinates,
            pieceEntities,
            secret
        );
    }
}
