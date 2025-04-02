// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.24;

import { MatchConfig, MatchConfigData } from "../codegen/tables/MatchConfig.sol";
import { MatchEntityCounter } from "../codegen/tables/MatchEntityCounter.sol";
import { MatchStatus } from "../codegen/tables/MatchStatus.sol";

import { MatchPlayer } from "../codegen/tables/MatchPlayer.sol";
import { Player } from "../codegen/tables/Player.sol";

import { Piece } from "../codegen/tables/Piece.sol";
import { PrimaryPiece } from "../codegen/tables/PrimaryPiece.sol";
import { Battle } from "../codegen/tables/Battle.sol";
import { Movement } from "../codegen/tables/Movement.sol";
import { OwnedBy } from "../codegen/tables/OwnedBy.sol";

import { PieceLibrary } from "../libraries/PieceLibrary.sol";
import { playerFromAddress } from "../libraries/LibUtils.sol";

function createMatchEntity(bytes32 matchEntity) returns (bytes32 entity) {
    uint256 entityId = MatchEntityCounter.get(matchEntity) + 1;
    // Register the new entity
    MatchEntityCounter.set(matchEntity, entityId);
    // Return the new entity id
    entity = bytes32(entityId);
}

function createPlayerEntity(
    bytes32 matchEntity,
    address playerAddress
) returns (bytes32) {
    bytes32 playerEntity = createMatchEntity(matchEntity);

    Player.set(matchEntity, playerEntity, true);
    MatchPlayer.set(matchEntity, playerAddress, playerEntity);

    return playerEntity;
}

function createPieceEntity(
    bytes32 _matchEntity,
    address _playerAddress,
    uint256 _pieceType
) returns (bytes32, PieceLibrary.Piece memory) {
    bytes32 pieceEntity = createMatchEntity(_matchEntity);

    PieceLibrary.Piece memory piece = PieceLibrary.getPiece(
        PieceLibrary.PieceType(_pieceType)
    );
    Piece.set(_matchEntity, pieceEntity, _pieceType);

    OwnedBy.set(
        _matchEntity,
        pieceEntity,
        playerFromAddress(_matchEntity, _playerAddress)
    );

    Movement.set(_matchEntity, pieceEntity, piece.movement);

    Battle.set(
        _matchEntity,
        pieceEntity,
        piece.health,
        piece.damage,
        piece.attackType,
        piece.range,
        piece.blindspot
    );

    return (pieceEntity, piece);
}

function createFortress(
    bytes32 _matchEntity,
    address _playerAddress
) returns (bytes32, PieceLibrary.Piece memory) {
    (bytes32 entity, PieceLibrary.Piece memory piece) = createPieceEntity(
        _matchEntity,
        _playerAddress,
        1
    );
    PrimaryPiece.setValue(_matchEntity, entity, true);
    return (entity, piece);
}
