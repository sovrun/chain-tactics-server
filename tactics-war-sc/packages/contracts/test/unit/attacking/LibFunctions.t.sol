// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { PositionData } from "src/codegen/tables/Position.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";
import { ICombatSystem } from "src/systems/interfaces/ICombatSystem.sol";

import { WorldSystemBuilder, SystemBuilder } from "../SystemBuilder.t.sol";

library LibFunctions {
    using SystemBuilder for WorldSystemBuilder;

    function moveOrAttack(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity,
        bytes32 entity,
        PositionData[] memory path
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(
                ICombatSystem.moveOrAttack,
                (matchEntity, entity, path)
            )
        );
    }

    function attack(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity,
        bytes32 entity,
        bytes32 target
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(ICombatSystem.attack, (matchEntity, entity, target))
        );
    }
}
