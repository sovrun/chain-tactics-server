// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { ITurnSystem } from "src/systems/interfaces/ITurnSystem.sol";

import { WorldSystemBuilder, SystemBuilder } from "../SystemBuilder.t.sol";

library LibFunctions {
    using SystemBuilder for WorldSystemBuilder;

    function endTurn(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(ITurnSystem.endTurn, (matchEntity))
        );
    }
}
