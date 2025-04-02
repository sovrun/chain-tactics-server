// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../../Base.t.sol";

import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { createMatchEntity, createPlayerEntity, createPieceEntity } from "src/utils/MatchEntityUtils.sol";
import { PieceLibrary } from "src/libraries/PieceLibrary.sol";

import { canAttack } from "src/utils/CombatUtils.sol";

import { BaseAttack_Test } from "./BaseAttack.t.sol";

contract lancer_Unit_Concrete_Test is BaseAttack_Test {
    bool logVisual = true;

    function test_lancer_attackTwoBlocks_returnTrue() public {
        // lancer can attack cross
        bool actualValue = canAttack(matchEntity, lancerEntity, 2, 1, 2, 3);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 1, 2, 3, actualValue);
    }

    function test_lancer_attackThreeBlocks_returnTrue() public {
        // lancer can attack cross
        bool actualValue = canAttack(matchEntity, lancerEntity, 2, 1, 2, 4);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 1, 2, 4, actualValue);
    }

    function test_lancer_attackOutOfRange_returnFalse() public {
        // footSoldier can attack cross
        bool actualValue = canAttack(
            matchEntity,
            footSoldierEntity,
            2,
            1,
            2,
            6
        );
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 1, 2, 6, actualValue);
    }

    function test_lancer_attackWithin_blindSpot_returnFalse() public {
        // lancer can attack cross
        bool actualValue = canAttack(matchEntity, lancerEntity, 2, 2, 2, 3);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 3, actualValue);
    }

    function test_lancer_attackDiagonal_returnFalse() public {
        bool actualValue = canAttack(matchEntity, lancerEntity, 2, 2, 3, 3);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 3, actualValue);
    }
}
