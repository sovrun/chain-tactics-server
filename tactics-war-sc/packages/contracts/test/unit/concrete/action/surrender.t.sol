// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseTurnSystem_Test } from "./BaseTurnSystem.sol";
import { console } from "forge-std/console.sol";

import { isFortress, playerFromAddress, pieceEntityCombat, isOwnedByAddress, isPositionOccupied, getEntityAtPosition, getEntityPosition } from "src/libraries/LibUtils.sol";

import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";

import { ActionStatus, ActionStatusData } from "src/codegen/tables/ActionStatus.sol";
import { ActivePlayer, ActivePlayerData } from "src/codegen/tables/ActivePlayer.sol";
import { MatchDefaultWinner } from "src/codegen/tables/MatchDefaultWinner.sol";

import { Errors } from "src/systems/TurnSystem.sol";
import { Errors as TurnErrors } from "src/systems/base/BaseTurn.sol";

import { MatchPlayerSurrenders } from "src/codegen/tables/MatchPlayerSurrenders.sol";
import { MatchWinner } from "src/codegen/tables/MatchWinner.sol";

contract surrender_Concrete_Test is BaseTurnSystem_Test {
    function test_secondPlayerWins_whenFirstPlayerSurrenders()
        public
        whenCallerAlice
    {
        surrender(_matchEntity);

        // assert that alice has surrendered
        assertTrue(
            MatchPlayerSurrenders.getValue(
                _matchEntity,
                playerFromAddress(_matchEntity, users.alice)
            )
        );

        uint256 currentActivePlayer = ActivePlayer.getPlayerIndex(_matchEntity);
        bytes32 actualResult = MatchPlayers.get(_matchEntity)[
            currentActivePlayer
        ];
        bytes32 expectedResult = playerFromAddress(_matchEntity, users.eve);
        assertEq(
            actualResult,
            expectedResult,
            "Current active player should be eve"
        );
        assertEq(
            actualResult,
            MatchWinner.get(_matchEntity),
            "Match winner should be eve"
        );
    }

    function test_revertGiven_playerAlreadySurrendered()
        public
        whenCallerAlice
    {
        surrender(_matchEntity);
        vm.expectRevert(Errors.TurnSystem__AlreadySurrendered.selector);
        surrender(_matchEntity);
    }

    function test_revertGiven_lastRemainingPlayerSurrendered()
        public
        whenCallerAlice
    {
        surrender(_matchEntity);

        // change prank to eve
        changePrank(users.eve);
        vm.expectRevert(Errors.TurnSystem__LastRemainingPlayer.selector);

        surrender(_matchEntity);
    }
}
