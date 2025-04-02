// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MatchPlayer } from "../codegen/tables/MatchPlayer.sol";

import { Battle, BattleData } from "../codegen/tables/Battle.sol";
import { Position, PositionData } from "../codegen/tables/Position.sol";
import { EntityAtPosition } from "../codegen/tables/EntityAtPosition.sol";
import { OwnedBy } from "../codegen/tables/OwnedBy.sol";
import { Piece } from "../codegen/tables/Piece.sol";
import { PrimaryPiece } from "../codegen/tables/PrimaryPiece.sol";
import { MatchPool } from "../codegen/tables/MatchPool.sol";
import { Inventory } from "../codegen/tables/Inventory.sol";
import { PieceLibrary } from "./PieceLibrary.sol";

function playerFromAddress(
    bytes32 _matchEntity,
    address _playerAddress
) view returns (bytes32) {
    return MatchPlayer.get(_matchEntity, _playerAddress);
}

function pieceEntityCombat(
    bytes32 _matchEntity,
    bytes32 _pieceEntity
) view returns (BattleData memory) {
    return Battle.get(_matchEntity, _pieceEntity);
}

function getOwningPlayer(
    bytes32 matchEntity,
    bytes32 entity
) view returns (bytes32) {
    return OwnedBy.get(matchEntity, entity);
}

function getEntityAtPosition(
    bytes32 matchEntity,
    uint32 x,
    uint32 y
) view returns (bytes32) {
    return EntityAtPosition.get(matchEntity, x, y);
}

function getEntityPosition(
    bytes32 matchEntity,
    bytes32 entity
) view returns (uint32, uint32) {
    PositionData memory position = Position.get(matchEntity, entity);
    return (position.x, position.y);
}

function isOwnedByAddress(
    bytes32 matchEntity,
    bytes32 entity,
    address owner
) view returns (bool) {
    bytes32 owningPlayer = getOwningPlayer(matchEntity, entity);
    bytes32 player = playerFromAddress(matchEntity, owner);

    return owningPlayer == player;
}

function isPositionOccupied(
    bytes32 matchEntity,
    uint32 x,
    uint32 y
) view returns (bool) {
    return getEntityAtPosition(matchEntity, x, y) != 0;
}

function isFortress(bytes32 matchEntity, bytes32 entity) view returns (bool) {
    return PrimaryPiece.getValue(matchEntity, entity);
}

function getPiecesOwnedByPlayer(
    bytes32 matchEntity,
    bytes32 playerEntity
) view returns (bytes32[] memory pieceEntities) {
    pieceEntities = Inventory.getPieces(matchEntity, playerEntity);
}
