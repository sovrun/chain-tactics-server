// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BasePlayerSystem_Test } from "../BasePlayerSystem.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { PlayerInGameName } from "src/codegen/tables/PlayerInGameName.sol";

import { Errors } from "src/common/Errors.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";
import { LibEntity } from "src/libraries/LibEntity.sol";

contract SetPlayerName_Unit_Concrete_Test is BasePlayerSystem_Test {
    using LibEntity for address payable;
    using LibEntity for bytes32;

    function test_RevertGiven_EmptyPlayerName() public whenCallerAlice {
        vm.expectRevert(Errors.EmptyPlayerName.selector);
        _setPlayerName("");
    }

    function test_setPlayerNameOfAlice() public whenCallerAlice {
        _setPlayerName("alice");

        assertEq(
            PlayerInGameName.getValue(users.alice.toPlayerEntity()),
            "alice",
            "Should have set player name, alice"
        );
    }

    function test_setPlayerNameOfEve() public whenCallerEve {
        _setPlayerName("eve");

        assertEq(
            PlayerInGameName.getValue(users.eve.toPlayerEntity()),
            "eve",
            "Should have set player name, eve"
        );
    }

    function test_setDuplicatePlayerNames() public {
        changePrank(users.alice);
        _setPlayerName("duplicate name");

        changePrank(users.eve);
        _setPlayerName("duplicate name");

        assertEq(
            PlayerInGameName.getValue(users.alice.toPlayerEntity()),
            PlayerInGameName.getValue(users.eve.toPlayerEntity()),
            "should be equal"
        );
    }
}
