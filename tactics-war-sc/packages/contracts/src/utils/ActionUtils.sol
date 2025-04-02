// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ActionStatus, ActionStatusData } from "../codegen/tables/ActionStatus.sol";
import { playerFromAddress } from "../libraries/LibUtils.sol";
import { LibAction } from "../libraries/LibAction.sol";

import { NUMBER_OF_MOVES_ALLOWED, NUMBER_OF_ATTACKS_ALLOWED } from "../common/constants.sol";

function hasLastAction(
    bytes32 matchEntity,
    bytes32 playerEntity
) view returns (bool) {
    return ActionStatus.getSelectedPiece(matchEntity, playerEntity) != 0;
}

function isValidNumberOfAttacks(
    bytes32 matchEntity,
    bytes32 playerEntity
) view returns (bool) {
    return
        ActionStatus.getBattlesExecuted(matchEntity, playerEntity) <
        NUMBER_OF_ATTACKS_ALLOWED;
}

function isValidNumberOfMoves(
    bytes32 matchEntity,
    bytes32 playerEntity
) view returns (bool) {
    return
        ActionStatus.getMovesExecuted(matchEntity, playerEntity) <
        NUMBER_OF_MOVES_ALLOWED;
}

function isActionValid(
    bytes32 matchEntity,
    address player,
    bytes32 pieceEntity,
    LibAction.ActionType actionType
) view returns (bool) {
    bytes32 playerEntity = playerFromAddress(matchEntity, player);
    ActionStatusData memory actionStatus = ActionStatus.get(
        matchEntity,
        playerEntity
    );
    if (hasLastAction(matchEntity, playerEntity)) {
        bool isValidNumberOfActions = actionType == LibAction.ActionType.MOVE
            ? isValidNumberOfMoves(matchEntity, playerEntity)
            : isValidNumberOfAttacks(matchEntity, playerEntity);
        return
            actionStatus.selectedPiece == pieceEntity && isValidNumberOfActions;
    } else {
        return true;
    }
}

function isActionConsumed(
    bytes32 matchEntity,
    address player
) view returns (bool) {
    bytes32 playerEntity = playerFromAddress(matchEntity, player);
    return
        !isValidNumberOfMoves(matchEntity, playerEntity) &&
        !isValidNumberOfAttacks(matchEntity, playerEntity);
}
