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

contract iceMage_Unit_Concrete_Test is BaseAttack_Test {
    bool logVisual = true;

    // iceMage can attack only diagonal

    function test_iceMage_attackOneBlockDiagonalTopLeft_returnTrue() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 1, 1);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 1, 1, actualValue);
    }

    function test_iceMage_attackOneBlockDiagonalTopRight_returnTrue() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 1, 3);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 1, 3, actualValue);
    }

    function test_iceMage_attackOneBlockDiagonalBottomLeft_returnTrue() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 3, 1);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 1, actualValue);
    }

    function test_iceMage_attackOneBlockDiagonalBottomRight_returnTrue()
        public
    {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 3, 3);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 3, actualValue);
    }

    function test_iceMage_attackTwoBlocksDiagonal_returnTrue() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 4, 4);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 4, 4, actualValue);
    }

    function test_iceMage_attackThreeBlocksDiagonal_returnTrue() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 5, 5);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 5, 5, actualValue);
    }

    function test_iceMage_attackHorizontal_returnFalse() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 2, 3);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 3, actualValue);
    }

    function test_iceMage_attackVertical_returnFalse() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 3, 2);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 3, 2, actualValue);
    }

    function test_iceMage_attackOutOfRangeDiagonal_returnFalse() public {
        bool actualValue = canAttack(matchEntity, iceMageEntity, 2, 2, 6, 6);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 6, 6, actualValue);
    }
}
