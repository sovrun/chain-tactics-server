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

contract priest_Unit_Concrete_Test is BaseAttack_Test {
    bool logVisual = true;

    function test_priest_attackOneBlockTopLeft_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 1, 1);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 1, 1, actualValue);
    }

    function test_priest_attackOneBlockTop_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 1, 2);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 1, 2, actualValue);
    }

    function test_priest_attackOneBlockTopRight_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 1, 3);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 1, 3, actualValue);
    }

    function test_priest_attackOneBlockRight_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 2, 3);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 3, actualValue);
    }

    function test_priest_attackOneBlockLeft_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 2, 1);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 1, actualValue);
    }

    function test_priest_attackOneBlockBottomLeft_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 3, 1);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 1, actualValue);
    }

    function test_priest_attackOneBlockBottom_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 3, 2);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 2, actualValue);
    }

    function test_priest_attackOneBlockBottomRight_returnTrue() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 3, 3);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 3, actualValue);
    }

    function test_priest_attackOutOfRange_returnFalse() public {
        // priest can attack square
        bool actualValue = canAttack(matchEntity, priestEntity, 2, 2, 2, 4);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 4, actualValue);
    }
}
