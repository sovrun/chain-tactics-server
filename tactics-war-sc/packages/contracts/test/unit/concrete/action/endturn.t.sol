// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseTurnSystem_Test } from "./BaseTurnSystem.sol";
import { console } from "forge-std/console.sol";

import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";

import { ActionStatus, ActionStatusData } from "src/codegen/tables/ActionStatus.sol";
import { ActivePlayer, ActivePlayerData } from "src/codegen/tables/ActivePlayer.sol";
import { MatchDefaultWinner } from "src/codegen/tables/MatchDefaultWinner.sol";

import { Errors } from "src/systems/TurnSystem.sol";
import { Errors as TurnErrors } from "src/systems/base/BaseTurn.sol";

import { TURN_DURATION } from "src/common/constants.sol";

contract Turn_Concrete_Test is BaseTurnSystem_Test {
    function _endTurnAndVerify(uint256 _newPlayerIndex) private {
        endTurn(_matchEntity);

        // removing this check as turn reset on every new move or attack
        // _verifyIfActionStatusResetForAllPlayers();

        // Verify if ActivePlayer is correctly updated
        uint256 activePlayerIndex = ActivePlayer.getPlayerIndex(_matchEntity);
        assertEq(
            activePlayerIndex,
            _newPlayerIndex,
            "Active Player Index mismatch"
        );
    }

    // Happy Path: Alice ends her turn successfully
    function test_end_turn_happy_path() public {
        ActionStatus.set(_matchEntity, _playerEntityAlice, _entityAlice, 0, 0);
        uint256 currentPlayerIndex = ActivePlayer.getPlayerIndex(_matchEntity);

        bytes32[] memory matchPlayers = MatchPlayers.get(_matchEntity);

        // Calculate the new player index
        uint256 newPlayerIndex = (currentPlayerIndex + 1) % matchPlayers.length;

        changePrank(users.alice);
        _endTurnAndVerify(newPlayerIndex);
    }

    // Revert Path: Eve tries to end turn when it's not her turn
    function test_end_turn_not_player_turn_revert() public {
        ActionStatus.set(_matchEntity, _playerEntityAlice, _entityAlice, 0, 0);

        changePrank(users.eve);
        // vm.expectRevert(Errors.TurnSystem__NotPlayerTurn.selector);
        vm.expectRevert(
            abi.encodeWithSelector(TurnErrors.NotPlayerTurn.selector, users.eve)
        );
        endTurn(_matchEntity);
    }

    // @note error
    // Happy Path: Check if all players made their first move, the default winner is set
    function test_end_turn_all_players_made_first_move() public {
        // Set first move for Alice
        ActionStatus.set(_matchEntity, _playerEntityAlice, _entityAlice, 1, 0);

        changePrank(users.alice);
        endTurn(_matchEntity);

        // Set first move for Eve
        changePrankToMudAdmin();
        ActionStatus.set(_matchEntity, _playerEntityEve, _entityEve, 0, 1);

        changePrank(users.eve);
        endTurn(_matchEntity);
    }

    // Revert Path: If Alice tries to end the turn twice consecutively
    function test_end_turn_consecutive_turn_revert() public {
        // Alice makes her move
        ActionStatus.set(_matchEntity, _playerEntityAlice, _entityAlice, 1, 0);

        // Alice ends her turn
        changePrank(users.alice);
        endTurn(_matchEntity);

        // Alice tries to end the turn again without any move
        // vm.expectRevert(Errors.TurnSystem__NotPlayerTurn.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                TurnErrors.NotPlayerTurn.selector,
                users.alice
            )
        );
        endTurn(_matchEntity);
    }

    // Revert Path: Verify turn switching logic, current player tries to end turn twice
    function test_end_turn_double_turn_revert() public {
        // Alice makes her move
        ActionStatus.set(_matchEntity, _playerEntityAlice, _entityAlice, 1, 0);

        // Alice ends her turn
        changePrank(users.alice);
        endTurn(_matchEntity);

        // Switch to Eve and make a move
        changePrankToMudAdmin();
        ActionStatus.set(_matchEntity, _playerEntityEve, _entityEve, 1, 0);

        // Eve ends her turn
        changePrank(users.eve);
        endTurn(_matchEntity);

        // Eve tries to end turn again without any move
        // vm.expectRevert(Errors.TurnSystem__NotPlayerTurn.selector);
        vm.expectRevert(
            abi.encodeWithSelector(TurnErrors.NotPlayerTurn.selector, users.eve)
        );
        endTurn(_matchEntity);
    }

    function test_endTurn_when_active_player_index_is_correct() public {
        changePrankToMudAdmin();
        ActivePlayer.set(_matchEntity, 0, block.timestamp);

        uint256 currentPlayerIndex = ActivePlayer.getPlayerIndex(_matchEntity);

        bytes32[] memory matchPlayers = MatchPlayers.get(_matchEntity);
        assertEq(
            matchPlayers[currentPlayerIndex],
            _playerEntityAlice,
            "Should be alice"
        );

        // Simulate to go to eve turn
        uint256 turnDuration = TURN_DURATION + 1;
        vm.warp(block.timestamp + turnDuration);

        changePrank(users.eve);
        endTurn(_matchEntity);

        uint256 newPlayerIndex = ActivePlayer.getPlayerIndex(_matchEntity);
        assertEq(newPlayerIndex, 0, "Should be alice again");
    }
}
