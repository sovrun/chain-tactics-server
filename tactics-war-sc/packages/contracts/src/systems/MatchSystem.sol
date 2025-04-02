// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { MatchConfig, MatchConfigData } from "../codegen/tables/MatchConfig.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { MatchPool } from "../codegen/tables/MatchPool.sol";

import { PlayerQueue } from "../codegen/tables/PlayerQueue.sol";
import { PlayerStatus, PlayerStatusData } from "../codegen/tables/PlayerStatus.sol";

import { MatchStatus } from "../codegen/tables/MatchStatus.sol";
import { MatchPlayerStatus } from "../codegen/tables/MatchPlayerStatus.sol";
import { MatchPreparationTime } from "../codegen/tables/MatchPreparationTime.sol";
import { MatchPlayerSurrenders } from "../codegen/tables/MatchPlayerSurrenders.sol";
import { SpawnStatus } from "../codegen/tables/SpawnStatus.sol";

import { Player } from "../codegen/tables/Player.sol";
import { MatchPlayer } from "../codegen/tables/MatchPlayer.sol";
import { Inventory } from "../codegen/tables/Inventory.sol";

import { hasPlayerSurrendered } from "../utils/TurnUtils.sol";

import { playerFromAddress } from "../libraries/LibUtils.sol";

import { BUY_PREP_TIME, GOLD_BALANCE, CLIENT_TRIGGER_DELAY } from "../common/constants.sol";
import { MatchStatusTypes, MatchPlayerStatusTypes, PlayerStatusTypes, SpawnStatusTypes } from "../common/types.sol";

import { Errors } from "../common/Errors.sol";

import { IMatchSystem } from "./interfaces/IMatchSystem.sol";

import { LibMatchWinner } from "../libraries/LibMatchWinner.sol";
import { LibMatch } from "../libraries/LibMatch.sol";
import { LibTurn } from "../libraries/LibTurn.sol";
import { LibArray } from "../libraries/LibArray.sol";

import { LibEntity } from "../libraries/LibEntity.sol";

import { LibPlayerStatusType } from "../libraries/types/LibPlayerStatusType.sol";
import { LibMatchStatusType } from "../libraries/types/LibMatchStatusType.sol";
import { LibMatchPlayerStatusType } from "../libraries/types/LibMatchPlayerStatusType.sol";
import { LibSpawnStatusType } from "../libraries/types/LibSpawnStatusType.sol";

import { playerFromAddress } from "../libraries/LibUtils.sol";

import { BaseMatch } from "./base/BaseMatch.sol";

contract MatchSystem is IMatchSystem, BaseMatch, System {
    using LibMatch for bytes32;

    using LibEntity for address;
    using LibEntity for bytes32;

    using LibPlayerStatusType for PlayerStatusTypes;
    using LibPlayerStatusType for uint8;

    using LibMatchStatusType for MatchStatusTypes;
    using LibMatchStatusType for uint8;

    using LibMatchPlayerStatusType for MatchPlayerStatusTypes;
    using LibMatchPlayerStatusType for uint8;

    using LibSpawnStatusType for SpawnStatusTypes;
    using LibSpawnStatusType for uint8;

    modifier onlyIfPlayerAvailable(address player) {
        PlayerStatusData memory playerData = PlayerStatus.get(
            player.toPlayerEntity()
        );

        PlayerStatusTypes playerStatus = playerData
            .status
            .toPlayerStatusTypes();

        if (playerStatus.isQueueing()) {
            revert Errors.PlayerAlreadyInQueue();
        }

        if (playerStatus.isPlaying()) {
            revert Errors.PlayerHasOngoingMatch();
        }

        _;
    }

    function joinQueue(
        bytes32 _boardEntity,
        bytes32 _modeEntity
    ) public override onlyIfPlayerAvailable(_msgSender()) {
        bytes32 playerEntity = _msgSender().toPlayerEntity();
        PlayerStatus.setStatus(
            playerEntity,
            PlayerStatusTypes.Queueing.toUint8()
        );

        bytes32 queueEntity = _boardEntity.toQueueEntity(_modeEntity);
        PlayerQueue.setValue(playerEntity, queueEntity);
        MatchPool.push(queueEntity, playerEntity);

        _tryCreateMatch(queueEntity, _boardEntity, _modeEntity, false);
    }

    function leave() public override {
        bytes32 playerEntity = _msgSender().toPlayerEntity();
        PlayerStatusData memory playerStatusData = PlayerStatus.get(
            playerEntity
        );

        PlayerStatusTypes playerStatus = playerStatusData
            .status
            .toPlayerStatusTypes();

        bytes32 matchEntity = playerStatusData.matchEntity;

        MatchStatusTypes matchStatus = MatchStatus
            .get(matchEntity)
            .toMatchStatusTypes();

        _requirePlayerIsInQueueOrMatch(playerStatus);

        if (playerStatus.isQueueing()) {
            bytes32 queueEntity = PlayerQueue.get(playerEntity);
            _leaveQueue(queueEntity, playerEntity);
        } else if (playerStatus.isPlaying() && matchStatus.isGameInProgress()) {
            _cancelMatch(matchEntity);
        } else if (playerStatus.isPlaying() && matchStatus.isActive()) {
            _surrenderOrCancel(matchEntity, playerStatusData.matchPlayerEntity);
        }
    }

    function setPlayerReadyAndStart(
        bytes32 _matchEntity
    )
        public
        override
        onlyMatchPreparingState(_matchEntity)
        onlyMatchPlayer(_matchEntity, _msgSender())
    {
        bytes32 matchPlayerEntity = MatchPlayer.get(_matchEntity, _msgSender());

        bool isPlayerReady = MatchPlayerStatus
            .get(_matchEntity, matchPlayerEntity)
            .toMatchPlayerStatusTypes()
            .isPlayerReady();
        if (isPlayerReady) {
            revert Errors.PlayerAlreadyReady();
        }

        MatchPlayerStatus.set(
            _matchEntity,
            matchPlayerEntity,
            MatchPlayerStatusTypes.Ready.toUint8()
        );

        bytes32[] memory matchPlayerEntities = MatchPlayers.get(_matchEntity);
        bool allPlayersReady = true;
        for (uint256 i = 0; i < matchPlayerEntities.length; i++) {
            bool isReady = MatchPlayerStatus
                .get(_matchEntity, matchPlayerEntities[i])
                .toMatchPlayerStatusTypes()
                .isPlayerReady();
            if (!isReady) {
                allPlayersReady = false;
                break;
            }
        }

        if (allPlayersReady) {
            for (uint256 i = 0; i < matchPlayerEntities.length; i++) {
                Inventory.setBalance(
                    _matchEntity,
                    matchPlayerEntities[i],
                    GOLD_BALANCE
                );
            }
            MatchStatus.set(_matchEntity, MatchStatusTypes.Active.toUint8());
            MatchPreparationTime.set(
                _matchEntity,
                block.timestamp + BUY_PREP_TIME
            );
        }
    }

    function claimVictory(
        bytes32 _matchEntity
    )
        public
        override
        onlyActiveMatch(_matchEntity)
        onlyMatchPlayer(_matchEntity, _msgSender())
    {
        _claimVictory(_matchEntity);
    }

    function _tryCreateMatch(
        bytes32 queueEntity,
        bytes32 boardEntity,
        bytes32 modeEntity,
        bool isPrivate
    ) internal {
        bytes32[] memory players = MatchPool.getPlayers(queueEntity);
        if (players.length < 2) {
            return;
        }

        // Generate match entity
        /// NOTE: if in case the players send multiple transactions with same details below,
        /// it would generate the same match entity.
        /// However, they will be prevented by `PlayerHasOngoingMatch()` custom error
        /// before they can get here.
        bytes32 matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                queueEntity,
                players[0],
                players[1]
            )
        );

        matchEntity.createMatch(boardEntity, modeEntity, isPrivate, players);

        _removeFromQueue(queueEntity, players[0]);
        _removeFromQueue(queueEntity, players[1]);
    }

    function _requirePlayerIsInQueueOrMatch(
        PlayerStatusTypes playerStatus
    ) internal pure {
        if (playerStatus.isNone()) {
            revert Errors.NotInQueueOrMatch();
        }
    }

    function _isOpponentActive(
        bytes32 matchEntity,
        bytes32 matchPlayerEntity
    ) internal view returns (bool, bytes32) {
        bytes32 opponent = _getPlayerOpponentEntity(
            matchEntity,
            matchPlayerEntity
        );

        SpawnStatusTypes opponentStatus = SpawnStatus
            .get(matchEntity, opponent)
            .toSpawnStatusTypes();

        bool isOpponentActive = SpawnStatus
            .get(matchEntity, matchPlayerEntity)
            .toSpawnStatusTypes()
            .isOpponentActive(matchEntity, opponentStatus);

        return (isOpponentActive, opponent);
    }

    function _getPlayerOpponentEntity(
        bytes32 matchEntity,
        bytes32 matchPlayerEntity
    ) internal view returns (bytes32) {
        bytes32[] memory matchPlayerEntities = MatchPlayers.get(matchEntity);
        return
            matchPlayerEntities[0] == matchPlayerEntity
                ? matchPlayerEntities[1]
                : matchPlayerEntities[0];
    }

    function _isPreparationPhaseOver(
        bytes32 matchEntity
    ) internal view returns (bool) {
        uint256 prepTime = MatchPreparationTime.get(matchEntity);
        // @note this delay is same for the client side to call leave function
        //  and expect that if two players didnt make any commitment then leave the match
        //  the expected behavior is to cancel the match, and same for claimVictory
        return block.timestamp > prepTime - CLIENT_TRIGGER_DELAY;
    }

    function _requireSpawnStatusNotNone(
        bytes32 matchEntity,
        bytes32 matchPlayerEntity
    ) internal view {
        if (
            SpawnStatus
                .get(matchEntity, matchPlayerEntity)
                .toSpawnStatusTypes()
                .isNone()
        ) {
            revert Errors.PlayerSpawnStatusNone();
        }
    }

    function _removeFromQueue(
        bytes32 queueEntity,
        bytes32 playerEntity
    ) internal {
        bytes32[] memory players = MatchPool.getPlayers(queueEntity);
        bytes32[] memory arrs = LibArray.filter(players, playerEntity);

        MatchPool.setPlayers(queueEntity, arrs);
        PlayerQueue.setValue(playerEntity, bytes32(0));
    }

    function _claimVictory(bytes32 matchEntity) internal {
        bytes32 matchPlayerEntity = playerFromAddress(
            matchEntity,
            _msgSender()
        );

        _requireSpawnStatusNotNone(matchEntity, matchPlayerEntity);

        (bool isActive, bytes32 opponent) = _isOpponentActive(
            matchEntity,
            matchPlayerEntity
        );
        if (isActive) {
            revert Errors.OpponentActive();
        }

        _setMatchWinnerAfterSurrender(matchEntity, opponent, matchPlayerEntity);
    }

    function _leaveQueue(bytes32 queueEntity, bytes32 playerEntity) internal {
        _removeFromQueue(queueEntity, playerEntity);
        PlayerStatus.setStatus(playerEntity, PlayerStatusTypes.None.toUint8());
    }

    function _cancelMatch(bytes32 matchEntity) internal {
        LibMatch.cancelMatch(matchEntity);
    }

    function _surrenderOrCancel(
        bytes32 matchEntity,
        bytes32 matchPlayerEntity
    ) internal {
        SpawnStatusTypes playerStatus = SpawnStatus
            .get(matchEntity, matchPlayerEntity)
            .toSpawnStatusTypes();

        bytes32 opponentEntity = _getPlayerOpponentEntity(
            matchEntity,
            matchPlayerEntity
        );
        SpawnStatusTypes opponentStatus = SpawnStatus
            .get(matchEntity, opponentEntity)
            .toSpawnStatusTypes();

        bool isPrepTimeOver = _isPreparationPhaseOver(matchEntity);

        if (
            isPrepTimeOver &&
            playerStatus == opponentStatus &&
            playerStatus < SpawnStatusTypes.Ready
        ) {
            _cancelMatch(matchEntity);
        } else {
            // Prevent surrender if the opponent is inactive after the prep phase
            // (commit and reveal phases), and the player accidentally clicks leave.
            if (isPrepTimeOver && playerStatus > opponentStatus) {
                _claimVictory(matchEntity);
            } else {
                _setMatchWinnerAfterSurrender(
                    matchEntity,
                    matchPlayerEntity,
                    opponentEntity
                );
            }
        }
    }

    function _setMatchWinnerAfterSurrender(
        bytes32 matchEntity,
        bytes32 surrenderingPlayerEntity,
        bytes32 winnerPlayerEntity
    ) internal {
        MatchPlayerSurrenders.set(matchEntity, surrenderingPlayerEntity, true);
        LibMatchWinner.setWinner(matchEntity, winnerPlayerEntity);
    }
}
