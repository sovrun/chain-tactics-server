// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../Base.t.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";
import { SystemBuilder, WorldSystemBuilder } from "../SystemBuilder.t.sol";
import { LibFunctions } from "./LibFunctions.t.sol";

contract BaseBuySystem_Test is Base_Test {
    using LibFunctions for WorldSystemBuilder;
    using SystemBuilder for IWorld;

    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function _commitBuy(bytes32 commitHash, bytes32 matchEntity) internal {
        world.buySystem().commitBuy(commitHash, matchEntity);
    }

    function _revealBuy(
        bytes32 matchEntity,
        uint256[] memory pieceTypes,
        bytes32 secret
    ) internal {
        world.buySystem().revealBuy(matchEntity, pieceTypes, secret);
    }
}
