// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseTurn } from "./base/BaseTurn.sol";
import { ITurnSystem } from "./interfaces/ITurnSystem.sol";

import { ActivePlayer } from "../codegen/tables/ActivePlayer.sol";
import { ActionStatus, ActionStatusData } from "../codegen/tables/ActionStatus.sol";

import { MatchPlayerSurrenders } from "../codegen/tables/MatchPlayerSurrenders.sol";

import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { LibMatch } from "../libraries/LibMatch.sol";
import { LibTurn } from "../libraries/LibTurn.sol";

import { pieceEntityCombat, isOwnedByAddress, getEntityAtPosition, getEntityPosition, isFortress, playerFromAddress } from "../libraries/LibUtils.sol";

import { recordPlayerActions } from "../utils/GameUtils.sol";
import { hasPlayerSurrendered, isLastRemainingPlayer } from "../utils/TurnUtils.sol";

import { TURN_TIMER } from "../common/constants.sol";

library Errors {
    error TurnSystem__NotPlayerTurn();
    error TurnSystem__AlreadySurrendered();
    error TurnSystem__LastRemainingPlayer();
}

contract TurnSystem is System, BaseTurn, ITurnSystem {
    /**
     * @notice Ends the turn for the current player in a match.
     * @param _matchEntity The identifier for the match in which the turn is being ended.
     * @dev Checks if the sender is the active player for the match. If not, it reverts with an error.
     * Then, it records the player's actions for the turn.
     * Example: A player calling `endTurn` to end their turn in a board game match.
     */
    function endTurn(
        bytes32 _matchEntity
    ) public override onlyCurrentPlayer(_matchEntity, _msgSender()) {
        LibTurn.advanceToNextActivePlayer(_matchEntity);
    }

    function surrender(bytes32 _matchEntity) public override {
        if (hasPlayerSurrendered(_matchEntity, _msgSender())) {
            revert Errors.TurnSystem__AlreadySurrendered();
        }

        if (isLastRemainingPlayer(_matchEntity)) {
            revert Errors.TurnSystem__LastRemainingPlayer();
        }

        LibTurn.surrenderPlayer(_matchEntity, _msgSender());
    }
}
