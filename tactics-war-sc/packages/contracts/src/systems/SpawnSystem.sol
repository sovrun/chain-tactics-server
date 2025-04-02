// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BoardConfig, BoardConfigData } from "../codegen/tables/BoardConfig.sol";
import { MatchConfig, MatchConfigData } from "../codegen/tables/MatchConfig.sol";
import { MatchPlayer } from "../codegen/tables/MatchPlayer.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { SpawnStatus } from "../codegen/tables/SpawnStatus.sol";
import { Position, PositionData } from "../codegen/tables/Position.sol";
import { EntityAtPosition } from "../codegen/tables/EntityAtPosition.sol";
import { Commit } from "../codegen/tables/Commit.sol";

import { LibSpawnStatusType } from "../libraries/types/LibSpawnStatusType.sol";
import { LibSpawn } from "../libraries/LibSpawn.sol";
import { LibPosition } from "../libraries/LibPosition.sol";
import { LibCommit } from "../libraries/LibCommit.sol";
import { playerFromAddress } from "../libraries/LibUtils.sol";
import { LibSpawn } from "../libraries/LibSpawn.sol";
import { SpawnStatusTypes } from "../common/types.sol";
import { Errors } from "../common/Errors.sol";

import { BaseMatch } from "./base/BaseMatch.sol";
import { BaseUnit } from "./base/BaseUnit.sol";

import { ISpawnSystem } from "./interfaces/ISpawnSystem.sol";

contract SpawnSystem is System, BaseMatch, BaseUnit, ISpawnSystem {
    using LibSpawnStatusType for SpawnStatusTypes;
    using LibSpawnStatusType for uint8;

    function commitSpawn(
        bytes32 _commitHash,
        bytes32 _matchEntity
    )
        public
        override
        onlyActiveMatch(_matchEntity)
        onlyIfPreparationTimeIsNotOver(_matchEntity)
        commitHashIsNotEmpty(_commitHash)
    {
        bytes32 matchPlayerEntity = playerFromAddress(
            _matchEntity,
            _msgSender()
        );
        _requireSpawnStatusToBeCommitSpawning(_matchEntity, matchPlayerEntity);

        LibCommit.setCommit(_matchEntity, matchPlayerEntity, _commitHash);
        LibSpawn.setSpawnStatus(
            _matchEntity,
            matchPlayerEntity,
            SpawnStatusTypes.LockCommitSpawning
        );
        _checkSpawnStatusAndProceed(
            _matchEntity,
            SpawnStatusTypes.LockCommitSpawning
        );
    }

    function revealSpawn(
        bytes32 _matchEntity,
        PositionData[] calldata _coordinates,
        bytes32[] calldata _pieceEntities,
        bytes32 _secret
    )
        public
        override
        onlyActiveMatch(_matchEntity)
        onlyIfPreparationTimeIsNotOver(_matchEntity)
    {
        bytes32 matchPlayerEntity = playerFromAddress(
            _matchEntity,
            _msgSender()
        );

        _requireSecretIsValid(_matchEntity, matchPlayerEntity);
        _requireEncodedHashIsEqualToCommitedHash(
            _matchEntity,
            matchPlayerEntity,
            _coordinates,
            _pieceEntities,
            _secret
        );

        MatchConfigData memory matchConfig = MatchConfig.get(_matchEntity);

        for (uint256 i = 0; i < _pieceEntities.length; i++) {
            PositionData memory coordinate = _coordinates[i];
            bytes32 pieceEntity = _pieceEntities[i];

            _requireSpawnPositionToBeValidCoordinates(
                matchConfig.boardEntity,
                coordinate
            );

            _requireSpawnPositionToBeValidSpawnArea(
                _matchEntity,
                matchPlayerEntity,
                matchConfig.boardEntity,
                coordinate
            );

            _requireSpawnPositionIsEmptyCoordinate(_matchEntity, coordinate);

            LibPosition.setPosition(_matchEntity, pieceEntity, coordinate);
        }

        LibSpawn.setSpawnStatus(
            _matchEntity,
            matchPlayerEntity,
            SpawnStatusTypes.LockRevealSpawning
        );
        _checkSpawnStatusAndProceed(
            _matchEntity,
            SpawnStatusTypes.LockRevealSpawning
        );
    }

    function _requireSpawnStatusToBeCommitSpawning(
        bytes32 _matchEntity,
        bytes32 matchPlayerEntity
    ) internal view {
        if (
            SpawnStatus
                .get(_matchEntity, matchPlayerEntity)
                .toSpawnStatusTypes()
                .isNotCommitSpawning()
        ) {
            revert Errors.IncorrectCommitStatus();
        }
    }

    function _requireEncodedHashIsEqualToCommitedHash(
        bytes32 _matchEntity,
        bytes32 _matchPlayerEntity,
        PositionData[] memory _coordinates,
        bytes32[] memory _pieceEntities,
        bytes32 _secret
    ) internal view {
        bytes32 commitHash = Commit.get(_matchEntity, _matchPlayerEntity);
        // Generate the combined hash from the piece types and secret
        bytes32 encodedCommitHash = keccak256(
            abi.encode(_pieceEntities, _coordinates, _secret)
        );

        if (encodedCommitHash != commitHash) {
            revert Errors.InvalidReveal();
        }
    }

    function _requireSecretIsValid(
        bytes32 _matchEntity,
        bytes32 _matchPlayerEntity
    ) internal view {
        if (
            SpawnStatus
                .get(_matchEntity, _matchPlayerEntity)
                .toSpawnStatusTypes()
                .isNotRevealSpawning()
        ) {
            revert Errors.IncorrectRevealStatus();
        }
    }

    function _requireSpawnPositionToBeValidCoordinates(
        bytes32 boardEntity,
        PositionData memory coordinate
    ) internal view {
        BoardConfigData memory boardConfigData = BoardConfig.get(boardEntity);
        bool isValidCoordinates = LibSpawn.isWithinBoardCoordinates(
            coordinate.x,
            coordinate.y,
            boardConfigData
        );
        if (!isValidCoordinates) {
            revert Errors.CoordinateNotAllowed();
        }
    }

    function _requireSpawnPositionToBeValidSpawnArea(
        bytes32 matchEntity,
        bytes32 matchPlayerEntity,
        bytes32 boardEntity,
        PositionData memory coordinate
    ) internal view {
        bool isValidSpawnArea = LibSpawn.isSpawnableArea(
            matchEntity,
            matchPlayerEntity,
            boardEntity,
            coordinate
        );
        if (!isValidSpawnArea) {
            revert Errors.NotInSpawnArea();
        }
    }

    function _requireSpawnPositionIsEmptyCoordinate(
        bytes32 matchEntity,
        PositionData memory coordinate
    ) internal view {
        bytes32 pieceEntity = EntityAtPosition.get(
            matchEntity,
            coordinate.x,
            coordinate.y
        );
        if (pieceEntity != 0) {
            revert Errors.PositionOccupied();
        }
    }
}
