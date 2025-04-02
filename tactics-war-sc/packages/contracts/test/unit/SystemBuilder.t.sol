// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";

import { TTW_NAMESPACES } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

struct WorldSystemBuilder {
    IWorld world;
    ResourceId systemId;
}

library SystemBuilder {
    using SystemIds for bytes14;

    function matchSystem(
        IWorld world
    ) internal pure returns (WorldSystemBuilder memory) {
        return
            WorldSystemBuilder({
                world: world,
                systemId: TTW_NAMESPACES.matchSystem()
            });
    }

    function buySystem(
        IWorld world
    ) internal pure returns (WorldSystemBuilder memory) {
        return
            WorldSystemBuilder({
                world: world,
                systemId: TTW_NAMESPACES.buySystem()
            });
    }

    function spawnSystem(
        IWorld world
    ) internal pure returns (WorldSystemBuilder memory) {
        return
            WorldSystemBuilder({
                world: world,
                systemId: TTW_NAMESPACES.spawnSystem()
            });
    }

    function moveSystem(
        IWorld world
    ) internal pure returns (WorldSystemBuilder memory) {
        return
            WorldSystemBuilder({
                world: world,
                systemId: TTW_NAMESPACES.moveSystem()
            });
    }

    function combatSystem(
        IWorld world
    ) internal pure returns (WorldSystemBuilder memory) {
        return
            WorldSystemBuilder({
                world: world,
                systemId: TTW_NAMESPACES.combatSystem()
            });
    }

    function turnSystem(
        IWorld world
    ) internal pure returns (WorldSystemBuilder memory) {
        return
            WorldSystemBuilder({
                world: world,
                systemId: TTW_NAMESPACES.turnSystem()
            });
    }

    function playerSystem(
        IWorld world
    ) internal pure returns (WorldSystemBuilder memory) {
        return
            WorldSystemBuilder({
                world: world,
                systemId: TTW_NAMESPACES.playerSystem()
            });
    }
}
