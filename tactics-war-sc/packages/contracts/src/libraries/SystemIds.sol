//SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { MATCH_SYSTEM, BUY_SYSTEM, SPAWN_SYSTEM, MOVE_SYSTEM, COMBAT_SYSTEM, TURN_SYSTEM, PLAYER_SYSTEM } from "../common/constants.sol";

library SystemIds {
    function matchSystem(bytes14 namespace) internal pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode({
                typeId: RESOURCE_SYSTEM,
                namespace: namespace,
                name: MATCH_SYSTEM
            });
    }

    function combatSystem(
        bytes14 namespace
    ) internal pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode({
                typeId: RESOURCE_SYSTEM,
                namespace: namespace,
                name: COMBAT_SYSTEM
            });
    }

    function buySystem(bytes14 namespace) internal pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode({
                typeId: RESOURCE_SYSTEM,
                namespace: namespace,
                name: BUY_SYSTEM
            });
    }

    function spawnSystem(bytes14 namespace) internal pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode({
                typeId: RESOURCE_SYSTEM,
                namespace: namespace,
                name: SPAWN_SYSTEM
            });
    }

    function moveSystem(bytes14 namespace) internal pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode({
                typeId: RESOURCE_SYSTEM,
                namespace: namespace,
                name: MOVE_SYSTEM
            });
    }

    function turnSystem(bytes14 namespace) internal pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode({
                typeId: RESOURCE_SYSTEM,
                namespace: namespace,
                name: TURN_SYSTEM
            });
    }

    function playerSystem(
        bytes14 namespace
    ) internal pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode({
                typeId: RESOURCE_SYSTEM,
                namespace: namespace,
                name: PLAYER_SYSTEM
            });
    }
}
