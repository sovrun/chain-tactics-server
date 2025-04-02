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

contract fireMage_Unit_Concrete_Test is BaseAttack_Test {
    bool logVisual = true;

    function test_fireMage_attackOneBlock_returnTrue() public {
        // fireMage can attack square
        bool actualValue = canAttack(matchEntity, fireMageEntity, 2, 2, 2, 3);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 3, actualValue);
    }

    function test_fireMage_attackTwoBlocksDiagonal_returnTrue() public {
        // fireMage can attack diamond
        bool actualValue = canAttack(matchEntity, fireMageEntity, 2, 2, 4, 4);
        bool expectedValue = true;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 4, 4, actualValue);
    }

    function test_fireMage_attackOutOfRange_returnFalse() public {
        // fireMage can attack square
        bool actualValue = canAttack(matchEntity, fireMageEntity, 2, 2, 2, 5);
        bool expectedValue = false;
        assertEq(expectedValue, actualValue);

        if (logVisual) visualizeBoard(2, 2, 2, 5, actualValue);
    }
}
