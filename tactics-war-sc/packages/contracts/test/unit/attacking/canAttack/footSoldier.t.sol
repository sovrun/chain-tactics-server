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

contract footSoldier_Unit_Concrete_Test is BaseAttack_Test {
    bool logVisual = true;

    function test_footSoldier_attackOnRangeTop_returnTrue() public {
        // footSoldier can attack cross
        bool actualValue = canAttack(
            matchEntity,
            footSoldierEntity,
            2,
            2,
            1,
            2
        );
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 1, 2, actualValue);
    }

    function test_footSoldier_attackOnRangeRight_returnTrue() public {
        // footSoldier can attack cross
        bool actualValue = canAttack(
            matchEntity,
            footSoldierEntity,
            2,
            2,
            2,
            3
        );
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 3, actualValue);
    }

    function test_footSoldier_attackOnRangeLeft_returnTrue() public {
        // footSoldier can attack cross
        bool actualValue = canAttack(
            matchEntity,
            footSoldierEntity,
            2,
            2,
            2,
            1
        );
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 1, actualValue);
    }

    function test_footSoldier_attackOnRangeBottom_returnTrue() public {
        // footSoldier can attack cross
        bool actualValue = canAttack(
            matchEntity,
            footSoldierEntity,
            2,
            2,
            3,
            2
        );
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 2, actualValue);
    }

    function test_footSoldier_attackDiagonal_returnFalse() public {
        bool actualValue = canAttack(
            matchEntity,
            footSoldierEntity,
            2,
            2,
            3,
            3
        );
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 3, actualValue);
    }

    function test_footSoldier_attackOutOfRange_returnFalse() public {
        // footSoldier can attack cross
        bool actualValue = canAttack(
            matchEntity,
            footSoldierEntity,
            1,
            1,
            1,
            3
        );
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(1, 1, 1, 3, actualValue);
    }
}
