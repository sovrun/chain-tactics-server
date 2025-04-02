// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.24;

import { BoardConfigData } from "../codegen/tables/BoardConfig.sol";
import { EntityAtPosition } from "../codegen/tables/EntityAtPosition.sol";
import { Position, PositionData } from "../codegen/tables/Position.sol";
import { LastMoveCommited } from "../codegen/tables/LastMoveCommited.sol";

import { playerFromAddress } from "src/libraries/LibUtils.sol";

function movePieceIntoANewPosition(
    bytes32 _matchEntity,
    bytes32 _entity,
    address _player,
    PositionData memory _currentCoordinate,
    PositionData memory _newCoordinate
) {
    EntityAtPosition.deleteRecord(
        _matchEntity,
        _currentCoordinate.x,
        _currentCoordinate.y
    );

    spawnPieceEntity(_matchEntity, _entity, _player, _newCoordinate);
}

function spawnPieceEntity(
    bytes32 _matchEntity,
    bytes32 _entity,
    address _player,
    PositionData memory _newCoordinate
) {
    bytes32 playerEntity = playerFromAddress(_matchEntity, _player);
    Position.set(_matchEntity, _entity, _newCoordinate.x, _newCoordinate.y);
    EntityAtPosition.setValue(
        _matchEntity,
        _newCoordinate.x,
        _newCoordinate.y,
        _entity
    );
    LastMoveCommited.set(
        _matchEntity,
        _entity,
        playerEntity,
        _player,
        _newCoordinate.x,
        _newCoordinate.y,
        block.timestamp
    );
}
