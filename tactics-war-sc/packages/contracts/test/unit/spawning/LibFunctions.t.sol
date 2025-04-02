// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES, SPAWN_SYSTEM } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { ISpawnSystem } from "src/systems/interfaces/ISpawnSystem.sol";

import { WorldSystemBuilder, SystemBuilder } from "../SystemBuilder.t.sol";

import { PositionData } from "src/codegen/tables/Position.sol";

library LibFunctions {
    using SystemBuilder for WorldSystemBuilder;

    function commitSpawn(
        WorldSystemBuilder memory builder,
        bytes32 commitHash,
        bytes32 matchEntity
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(ISpawnSystem.commitSpawn, (commitHash, matchEntity))
        );
    }

    function revealSpawn(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity,
        PositionData[] memory coordinates,
        bytes32[] memory pieceEntities,
        bytes32 secret
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(
                ISpawnSystem.revealSpawn,
                (matchEntity, coordinates, pieceEntities, secret)
            )
        );
    }
}
