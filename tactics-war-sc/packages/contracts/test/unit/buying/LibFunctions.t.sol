// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES, BUY_SYSTEM } from "src/common/constants.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { IBuySystem } from "src/systems/interfaces/IBuySystem.sol";

import { WorldSystemBuilder, SystemBuilder } from "../SystemBuilder.t.sol";

library LibFunctions {
    using SystemBuilder for WorldSystemBuilder;

    function commitBuy(
        WorldSystemBuilder memory builder,
        bytes32 commitHash,
        bytes32 matchEntity
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(IBuySystem.commitBuy, (commitHash, matchEntity))
        );
    }

    function revealBuy(
        WorldSystemBuilder memory builder,
        bytes32 matchEntity,
        uint256[] memory pieceTypes,
        bytes32 secret
    ) internal {
        builder.world.call(
            builder.systemId,
            abi.encodeCall(
                IBuySystem.revealBuy,
                (matchEntity, pieceTypes, secret)
            )
        );
    }
}
