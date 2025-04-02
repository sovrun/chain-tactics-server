// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../Base.t.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { TTW_NAMESPACES, MATCH_SYSTEM } from "src/common/constants.sol";
import { PlayerStatusTypes } from "src/common/types.sol";

import { PlayerInGameName } from "src/codegen/tables/PlayerInGameName.sol";

import { IWorld } from "src/codegen/world/IWorld.sol";
import { SystemBuilder, WorldSystemBuilder } from "../SystemBuilder.t.sol";
import { LibFunctions } from "./LibFunctions.t.sol";

contract BasePlayerSystem_Test is Base_Test {
    using LibFunctions for WorldSystemBuilder;
    using SystemBuilder for IWorld;

    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function _setPlayerName(string memory name) internal {
        world.playerSystem().setPlayerName(name);
    }
}
