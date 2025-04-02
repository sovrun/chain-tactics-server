// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ActionStatus, ActionStatusData } from "../codegen/tables/ActionStatus.sol";

import { playerFromAddress } from "../libraries/LibUtils.sol";
import { hasLastAction } from "../utils/ActionUtils.sol";

import { NUMBER_OF_MOVES_ALLOWED, NUMBER_OF_ATTACKS_ALLOWED } from "../common/constants.sol";

library LibAction {
    enum ActionType {
        MOVE,
        ATTACK
    }

    function setActivePiece(
        bytes32 matchEntity,
        bytes32 playerEntity,
        bytes32 activePiece
    ) internal {
        ActionStatus.setSelectedPiece(matchEntity, playerEntity, activePiece);
    }

    function incrementPlayerMoveCount(
        bytes32 matchEntity,
        bytes32 playerEntity
    ) internal {
        uint256 numberOfMoves = ActionStatus.getMovesExecuted(
            matchEntity,
            playerEntity
        );
        ActionStatus.setMovesExecuted(
            matchEntity,
            playerEntity,
            numberOfMoves + 1
        );
    }

    function incrementPlayerAttackCount(
        bytes32 matchEntity,
        bytes32 playerEntity
    ) internal {
        uint256 numberOfAttacks = ActionStatus.getBattlesExecuted(
            matchEntity,
            playerEntity
        );
        ActionStatus.setBattlesExecuted(
            matchEntity,
            playerEntity,
            numberOfAttacks + 1
        );
    }

    /// @dev Call `ActionUtils.isActionValid` before setting the player action
    function executePlayerAction(
        bytes32 matchEntity,
        address player,
        bytes32 pieceEntity,
        ActionType actionType
    ) internal {
        bytes32 playerEntity = playerFromAddress(matchEntity, player);
        if (!hasLastAction(matchEntity, playerEntity)) {
            setActivePiece(matchEntity, playerEntity, pieceEntity);
        }
        if (actionType == ActionType.MOVE) {
            incrementPlayerMoveCount(matchEntity, playerEntity);
        } else {
            incrementPlayerAttackCount(matchEntity, playerEntity);
        }
    }
}
