// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.24;

import { MatchConfig, MatchConfigData } from "../codegen/tables/MatchConfig.sol";
import { MatchEntityCounter } from "../codegen/tables/MatchEntityCounter.sol";
import { MatchPlayerStatus } from "../codegen/tables/MatchPlayerStatus.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { MatchStatus } from "../codegen/tables/MatchStatus.sol";

import { PlayersInMatch } from "../codegen/tables/PlayersInMatch.sol";
import { PlayerStatus } from "../codegen/tables/PlayerStatus.sol";
import { PlayerQueue } from "../codegen/tables/PlayerQueue.sol";
import { MatchPool } from "../codegen/tables/MatchPool.sol";

import { createPlayerEntity } from "../utils/MatchEntityUtils.sol";

import { LibEntity } from "../libraries/LibEntity.sol";

import { LibMatchStatusType } from "../libraries/types/LibMatchStatusType.sol";
import { LibPlayerStatusType } from "../libraries/types/LibPlayerStatusType.sol";

import { MatchStatusTypes, MatchPlayerStatusTypes, PlayerStatusTypes } from "../common/types.sol";
import { Errors } from "../common/Errors.sol";

library LibMatch {
    using LibMatchStatusType for MatchStatusTypes;
    using LibPlayerStatusType for PlayerStatusTypes;

    function createMatch(
        bytes32 _matchEntity,
        bytes32 _boardEntity,
        bytes32 _modeEntity,
        bool _isPrivate,
        bytes32[] memory _playerEntities
    ) internal {
        uint playerCount = _playerEntities.length;

        // Set match config
        MatchConfigData memory matchConfig = MatchConfigData({
            boardEntity: _boardEntity,
            gameModeEntity: _modeEntity,
            playerCount: playerCount,
            isPrivate: _isPrivate,
            createdBy: LibEntity.entityToAddress(_playerEntities[0])
        });
        MatchConfig.set(_matchEntity, matchConfig);

        PlayersInMatch.set(_matchEntity, _playerEntities);

        // Set player entities
        bytes32[] memory matchPlayerEntities = new bytes32[](playerCount);
        uint256 counter = 0;
        for (counter; counter < playerCount; counter++) {
            bytes32 playerEntity = _playerEntities[counter];
            // TODO: In the future, `MatchEntityUtils.createPlayerEntity` will be removed and replaced by `LibEntity.toPlayerEntity`.
            // LibEntity.toPlayerEntity: converts a player's address to a `bytes32`.
            // This change aims to simplify the implementation of player entity creation.
            bytes32 matchPlayerEntity = createPlayerEntity(
                _matchEntity,
                // Convert bytes32 entity to address for compatibility
                LibEntity.entityToAddress(playerEntity)
            );
            matchPlayerEntities[counter] = matchPlayerEntity;

            // TODO recheck if game dev needs this
            MatchPlayerStatus.set(
                _matchEntity,
                matchPlayerEntity,
                uint8(MatchPlayerStatusTypes.Matched)
            );

            PlayerStatus.set(
                playerEntity,
                _matchEntity,
                matchPlayerEntity,
                PlayerStatusTypes.Playing.toUint8()
            );
        }

        MatchPlayers.set(_matchEntity, matchPlayerEntities);
        // Set match status
        MatchStatus.set(_matchEntity, MatchStatusTypes.Preparing.toUint8());
    }

    function cancelMatch(bytes32 _matchEntity) internal {
        resetMatchPlayersStatus(_matchEntity);
        MatchStatus.set(_matchEntity, MatchStatusTypes.Cancelled.toUint8());
    }

    function finishMatch(bytes32 _matchEntity) internal {
        resetMatchPlayersStatus(_matchEntity);
        MatchStatus.set(_matchEntity, MatchStatusTypes.Finished.toUint8());
    }

    function resetMatchPlayersStatus(bytes32 _matchEntity) internal {
        bytes32[] memory playerEntities = PlayersInMatch.get(_matchEntity);
        uint256 counter;
        for (; counter < playerEntities.length; counter++) {
            resetMatchPlayerStatus(playerEntities[counter]);
        }
    }

    function resetMatchPlayerStatus(bytes32 _playerEntity) internal {
        PlayerStatus.set(_playerEntity, bytes32(0), bytes32(0), 0);
    }
}
