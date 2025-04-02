// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES, MATCH_SYSTEM } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { IMatchSystem } from "src/systems/interfaces/IMatchSystem.sol";

import { WorldSystemBuilder, SystemBuilder } from "../SystemBuilder.t.sol";

library LibFunctions {
    using SystemBuilder for WorldSystemBuilder;

    function joinQueue(
        WorldSystemBuilder memory builder,
        bytes32 boardEntity,
        bytes32 modeEntity
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(IMatchSystem.joinQueue, (boardEntity, modeEntity))
        );
    }

    function setPlayerReadyAndStart(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(IMatchSystem.setPlayerReadyAndStart, (matchEntity))
        );
    }

    function leave(WorldSystemBuilder memory builder) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(IMatchSystem.leave, ())
        );
    }

    function claimVictory(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(IMatchSystem.claimVictory, (matchEntity))
        );
    }
}
