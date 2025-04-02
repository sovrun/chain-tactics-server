// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.24;

import { ActivePlayer, ActivePlayerData } from "../codegen/tables/ActivePlayer.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { MatchPlayerSurrenders } from "../codegen/tables/MatchPlayerSurrenders.sol";
import { MatchSurrenderCount } from "../codegen/tables/MatchSurrenderCount.sol";

import { playerFromAddress } from "../libraries/LibUtils.sol";

import { TURN_DURATION } from "../common/constants.sol";

function calculateCurrentTurnIndex(bytes32 matchEntity) view returns (uint256) {
    ActivePlayerData memory turnData = ActivePlayer.get(matchEntity);
    uint256 lastTurnTimestamp = turnData.timestamp;

    uint256 turnsPassed = (block.timestamp - lastTurnTimestamp) / TURN_DURATION;

    bytes32[] memory players = MatchPlayers.get(matchEntity);
    uint256 totalPlayers = players.length;

    uint256 currentTurnIndex = (turnData.playerIndex + turnsPassed) %
        totalPlayers;

    while (hasPlayerSurrendered(matchEntity, players[currentTurnIndex])) {
        currentTurnIndex = (currentTurnIndex + 1) % totalPlayers;
    }

    return currentTurnIndex;
}

function isCurrentPlayerTurn(
    bytes32 matchEntity,
    address player
) view returns (bool) {
    bytes32 playerEntity = playerFromAddress(matchEntity, player);

    bytes32[] memory players = MatchPlayers.get(matchEntity);
    uint256 currentTurnIndex = calculateCurrentTurnIndex(matchEntity);
    bytes32 currentPlayerTurnEntity = players[currentTurnIndex];

    return currentPlayerTurnEntity == playerEntity;
}

function isNewTurn(bytes32 matchEntity) view returns (bool) {
    ActivePlayerData memory turnData = ActivePlayer.get(matchEntity);
    uint256 lastTurnTimestamp = turnData.timestamp;

    return block.timestamp > lastTurnTimestamp + TURN_DURATION;
}

function isValidTurn(bytes32 matchEntity, address player) view returns (bool) {
    return isCurrentPlayerTurn(matchEntity, player);
}

function hasPlayerSurrendered(
    bytes32 matchEntity,
    address player
) view returns (bool) {
    bytes32 playerEntity = playerFromAddress(matchEntity, player);
    return MatchPlayerSurrenders.get(matchEntity, playerEntity);
}

function hasPlayerSurrendered(
    bytes32 matchEntity,
    bytes32 playerEntity
) view returns (bool) {
    return MatchPlayerSurrenders.get(matchEntity, playerEntity);
}

function isLastRemainingPlayer(bytes32 matchEntity) view returns (bool) {
    bytes32[] memory players = MatchPlayers.get(matchEntity);
    uint256 totalPlayers = players.length;
    uint256 totalPlayerSurrendered = MatchSurrenderCount.get(matchEntity);

    return totalPlayers - totalPlayerSurrendered == 1;
}
