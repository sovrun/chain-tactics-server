// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { LibMatchWinner } from "./LibMatchWinner.sol";

import { ActivePlayer, ActivePlayerData } from "../codegen/tables/ActivePlayer.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { MatchPlayerSurrenders } from "../codegen/tables/MatchPlayerSurrenders.sol";
import { MatchSurrenderCount } from "../codegen/tables/MatchSurrenderCount.sol";

import { playerFromAddress } from "../libraries/LibUtils.sol";
import { calculateCurrentTurnIndex, isNewTurn, isLastRemainingPlayer, hasPlayerSurrendered, isCurrentPlayerTurn } from "../utils/TurnUtils.sol";
import { resetPlayerActions } from "../utils/GameUtils.sol";

import { TURN_DURATION } from "../common/constants.sol";

library LibTurn {
    function resetPlayerActionIfNewTurn(
        bytes32 matchEntity,
        address player
    ) internal {
        if (isNewTurn(matchEntity)) {
            resetPlayerActions(
                matchEntity,
                playerFromAddress(matchEntity, player)
            );
        }
    }

    function advanceToNextPlayer(bytes32 matchEntity) internal {
        ActivePlayerData memory turnData = ActivePlayer.get(matchEntity);

        bytes32[] memory players = MatchPlayers.get(matchEntity);
        uint256 totalPlayers = players.length;

        ActivePlayer.set(
            matchEntity,
            ActivePlayerData({
                playerIndex: ((turnData.playerIndex + 1) % totalPlayers),
                timestamp: block.timestamp
            })
        );
    }

    function advanceToNextActivePlayer(bytes32 matchEntity) internal {
        bytes32[] memory players = MatchPlayers.get(matchEntity);
        uint256 totalPlayers = players.length;

        uint256 currentTurnIndex = calculateCurrentTurnIndex(matchEntity);

        uint256 nextPlayerIndex = (currentTurnIndex + 1) % totalPlayers;
        while (hasPlayerSurrendered(matchEntity, players[nextPlayerIndex])) {
            nextPlayerIndex = (nextPlayerIndex + 1) % totalPlayers;
        }

        ActivePlayer.set(
            matchEntity,
            ActivePlayerData({
                playerIndex: nextPlayerIndex,
                timestamp: block.timestamp
            })
        );
        resetPlayerActions(matchEntity, players[nextPlayerIndex]);
    }

    function surrenderPlayer(bytes32 matchEntity, address player) internal {
        bytes32 playerEntity = playerFromAddress(matchEntity, player);

        if (isCurrentPlayerTurn(matchEntity, player)) {
            advanceToNextActivePlayer(matchEntity);
        }

        MatchPlayerSurrenders.set(matchEntity, playerEntity, true);

        bytes32[] memory players = MatchPlayers.get(matchEntity);
        uint256 totalPlayerSurrendered = MatchSurrenderCount.get(matchEntity);
        MatchSurrenderCount.setValue(matchEntity, totalPlayerSurrendered + 1);

        if (isLastRemainingPlayer(matchEntity)) {
            uint256 currentActivePlayer = ActivePlayer
                .get(matchEntity)
                .playerIndex;
            LibMatchWinner.setWinner(matchEntity, players[currentActivePlayer]);
        }
    }
}
