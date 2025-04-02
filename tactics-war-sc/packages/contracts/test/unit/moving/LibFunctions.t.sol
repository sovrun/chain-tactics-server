// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES, SPAWN_SYSTEM } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { IMoveSystem } from "src/systems/interfaces/IMoveSystem.sol";

import { WorldSystemBuilder, SystemBuilder } from "../SystemBuilder.t.sol";

import { PositionData } from "src/codegen/tables/Position.sol";

library LibFunctions {
    using SystemBuilder for WorldSystemBuilder;

    function move(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity,
        bytes32 entity,
        PositionData[] memory path
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(IMoveSystem.move, (matchEntity, entity, path))
        );
    }
}
