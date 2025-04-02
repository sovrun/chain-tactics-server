// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { TURN_DURATION } from "src/common/constants.sol";

import { BaseSurrender_Test } from "./BaseSurrender.t.sol";
import { Errors } from "src/systems/CombatSystem.sol";

import { isFortress, playerFromAddress, pieceEntityCombat, isOwnedByAddress, isPositionOccupied, getEntityAtPosition, getEntityPosition } from "src/libraries/LibUtils.sol";

import { Position, PositionData } from "src/codegen/tables/Position.sol";
import { Battle, BattleData } from "src/codegen/tables/Battle.sol";
import { ActivePlayer } from "src/codegen/tables/ActivePlayer.sol";
import { MatchWinner } from "src/codegen/tables/MatchWinner.sol";
import { MatchStatus } from "src/codegen/tables/MatchStatus.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { MatchPlayerSurrenders } from "src/codegen/tables/MatchPlayerSurrenders.sol";

import { LibTurn } from "src/libraries/LibTurn.sol";
import { calculateCurrentTurnIndex } from "src/utils/TurnUtils.sol";
import { isFortressDestroyed } from "src/utils/CombatUtils.sol";

contract surrender_Unit_Concrete_Test is BaseSurrender_Test {
    function test_secondPlayerWins_whenFirstPlayerSurrenders() public {
        // surrender alice
        LibTurn.surrenderPlayer(matchEntity, users.alice);
        assertTrue(
            MatchPlayerSurrenders.getValue(
                matchEntity,
                playerFromAddress(matchEntity, users.alice)
            )
        );

        uint256 currentActivePlayer = ActivePlayer.getPlayerIndex(matchEntity);
        bytes32 actualResult = MatchPlayers.get(matchEntity)[
            currentActivePlayer
        ];
        bytes32 expectedResult = playerFromAddress(matchEntity, users.eve);
        assertEq(
            actualResult,
            expectedResult,
            "Current active player should be eve"
        );
        assertEq(
            actualResult,
            MatchWinner.get(matchEntity),
            "Match winner should be eve"
        );
    }

    function test_threePlayer_andCheckCurrentActivePlayer() public {
        MatchPlayers.pushValue(matchEntity, bobEntity);

        // moved to eve's turn
        vm.warp(block.timestamp + TURN_DURATION + 1);
        uint256 turnIndex = calculateCurrentTurnIndex(matchEntity);
        bytes32 expectedEntityTurn = MatchPlayers.get(matchEntity)[turnIndex];
        assertEq(
            playerFromAddress(matchEntity, users.eve),
            expectedEntityTurn,
            "Current active player should be eve"
        );

        // surrender bob
        LibTurn.surrenderPlayer(matchEntity, users.bob);

        // get the current player index
        uint256 currentActivePlayerIndex = calculateCurrentTurnIndex(
            matchEntity
        );
        bytes32 actualResult = MatchPlayers.get(matchEntity)[
            currentActivePlayerIndex
        ];
        bytes32 expectedResult = playerFromAddress(matchEntity, users.eve);
        assertEq(
            actualResult,
            expectedResult,
            "Match player turn should be eve"
        );

        // moved to alice's turn
        vm.warp(block.timestamp + TURN_DURATION + 1);
        turnIndex = calculateCurrentTurnIndex(matchEntity);
        expectedEntityTurn = MatchPlayers.get(matchEntity)[turnIndex];
        assertEq(
            playerFromAddress(matchEntity, users.alice),
            expectedEntityTurn,
            "Current active player should be alice"
        );
    }
}
