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

contract archer_Unit_Concrete_Test is BaseAttack_Test {
    bool logVisual = true;

    function test_archer_attackOneBlock_returnFalse() public {
        // archer can attack square
        bool actualValue = canAttack(matchEntity, archerEntity, 2, 2, 2, 3);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 3, actualValue);
    }

    function test_archer_attackTwoBlock_returnFalse() public {
        // archer can attack square
        bool actualValue = canAttack(matchEntity, archerEntity, 2, 2, 2, 4);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 4, actualValue);
    }

    function test_archer_attackThreeBlocksDiagonal_returnTrue() public {
        // archer can attack diagonal
        bool actualValue = canAttack(matchEntity, archerEntity, 2, 2, 5, 5);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 5, 5, actualValue);
    }

    function test_archer_attackFourBlocksDiagonal_returnTrue() public {
        // archer can attack diagonal
        bool actualValue = canAttack(matchEntity, archerEntity, 2, 2, 2, 6);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 6, actualValue);
    }

    function test_archer_attackOutOfRange_returnFalse() public {
        // archer can attack square
        bool actualValue = canAttack(matchEntity, archerEntity, 2, 2, 2, 7);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 7, actualValue);
    }
}
