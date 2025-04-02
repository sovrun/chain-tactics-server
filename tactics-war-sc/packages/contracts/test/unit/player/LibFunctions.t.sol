// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES, MATCH_SYSTEM } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { IPlayerSystem } from "src/systems/interfaces/IPlayerSystem.sol";

import { WorldSystemBuilder, SystemBuilder } from "../SystemBuilder.t.sol";

library LibFunctions {
    using SystemBuilder for WorldSystemBuilder;

    function setPlayerName(
        WorldSystemBuilder memory builder,
        string memory name
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(IPlayerSystem.setPlayerName, (name))
        );
    }
}
