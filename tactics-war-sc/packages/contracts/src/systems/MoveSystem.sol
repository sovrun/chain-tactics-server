// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { BoardConfig, BoardConfigData } from "../codegen/tables/BoardConfig.sol";
import { Position, PositionData } from "../codegen/tables/Position.sol";
import { EntityAtPosition } from "../codegen/tables/EntityAtPosition.sol";
import { Movement } from "../codegen/tables/Movement.sol";
import { OwnedBy } from "../codegen/tables/OwnedBy.sol";
import { ActionStatus, ActionStatusData } from "../codegen/tables/ActionStatus.sol";
import { ActivePlayer } from "../codegen/tables/ActivePlayer.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";

import { BaseMatch } from "./base/BaseMatch.sol";
import { BaseTurn } from "./base/BaseTurn.sol";

import { LibAction } from "../libraries/LibAction.sol";
import { LibTurn } from "../libraries/LibTurn.sol";

import { isActionConsumed, isActionValid, isValidNumberOfMoves } from "../utils/ActionUtils.sol";
import { movePieceIntoANewPosition } from "../utils/UnitUtils.sol";
import { resetPlayerActions } from "../utils/GameUtils.sol";

import { entityToPosition, distanceBetweenTarget, isValidPathStep } from "../common/Utils.sol";
import { playerFromAddress, pieceEntityCombat, isOwnedByAddress, isPositionOccupied, getEntityAtPosition, getEntityPosition, playerFromAddress } from "../libraries/LibUtils.sol";
import { NUMBER_OF_MOVES_ALLOWED } from "../common/constants.sol";
import { Errors } from "../common/Errors.sol";

import { IMoveSystem } from "./interfaces/IMoveSystem.sol";

contract MoveSystem is System, BaseTurn, BaseMatch, IMoveSystem {
    function move(
        bytes32 _matchEntity,
        bytes32 _entity,
        PositionData[] memory _path
    )
        public
        override
        onlyActiveMatch(_matchEntity)
        onlyCurrentPlayer(_matchEntity, _msgSender())
    {
        _requireValidNumberOfMoves(_matchEntity, _msgSender());
        _requireSelectedPiece(_matchEntity, _entity, _msgSender());
        _requireOwnerOfPiece(_matchEntity, _entity, _msgSender());

        _movePiece(_matchEntity, _entity, _path);

        LibAction.executePlayerAction(
            _matchEntity,
            _msgSender(),
            _entity,
            LibAction.ActionType.MOVE
        );
    }

    function _movePiece(
        bytes32 _matchEntity,
        bytes32 _entity,
        PositionData[] memory _path
    ) internal {
        // Initialize position data and movement points
        PositionData memory positionData = Position.get(_matchEntity, _entity);
        uint256 movement = Movement.getValue(_matchEntity, _entity);

        _requirePieceExistence(_matchEntity, positionData.x, positionData.y);
        _calculateMove(_matchEntity, positionData, _path, movement);

        // Initialize target position
        uint32 targetX = _path[_path.length - 1].x;
        uint32 targetY = _path[_path.length - 1].y;
        PositionData memory newTargetCoordinate = PositionData(
            targetX,
            targetY
        );

        movePieceIntoANewPosition(
            _matchEntity,
            _entity,
            _msgSender(),
            positionData,
            newTargetCoordinate
        );
    }

    function _calculateMove(
        bytes32 _matchEntity,
        PositionData memory _positionData,
        PositionData[] memory _path,
        uint256 _movement
    ) internal view {
        PositionData memory currentPiecePosition = _positionData;
        uint256 distanceCounter;

        for (uint256 i; i < _path.length; i++) {
            PositionData memory targetPosition = _path[i];
            uint32 distance = distanceBetweenTarget(
                currentPiecePosition,
                targetPosition
            );

            _requireDiagonalNotAllowed(currentPiecePosition, targetPosition);

            distanceCounter += distance;
            _requireValidDistance(distanceCounter, _movement);

            _requireCoordinatesAreNotOccupied(
                _matchEntity,
                _path[i].x,
                _path[i].y
            );
            currentPiecePosition = targetPosition;
        }
    }

    function _requireValidNumberOfMoves(
        bytes32 _matchEntity,
        address _playerAddress
    ) internal view {
        bool isMoveValid = isValidNumberOfMoves(
            _matchEntity,
            playerFromAddress(_matchEntity, _playerAddress)
        );
        if (!isMoveValid) {
            revert Errors.ExceededMovesAllowed();
        }
    }

    function _requireSelectedPiece(
        bytes32 _matchEntity,
        bytes32 _entity,
        address _playerAddress
    ) internal view {
        bool isSelectedPieceValid = isActionValid(
            _matchEntity,
            _playerAddress,
            _entity,
            LibAction.ActionType.MOVE
        );
        if (!isSelectedPieceValid) {
            revert Errors.NotSelectedPiece();
        }
    }

    function _requireDiagonalNotAllowed(
        PositionData memory _currentPiecePosition,
        PositionData memory _targetPosition
    ) internal pure {
        if (!isValidPathStep(_currentPiecePosition, _targetPosition)) {
            revert Errors.InvalidPath();
        }
    }

    function _requireValidDistance(
        uint256 _distanceCounter,
        uint256 _movement
    ) internal pure {
        if (_distanceCounter > _movement || _distanceCounter < 1) {
            revert Errors.InvalidMove();
        }
    }

    function _requirePieceExistence(
        bytes32 _matchEntity,
        uint32 _x,
        uint32 _y
    ) internal view {
        if (!isPositionOccupied(_matchEntity, _x, _y)) {
            revert Errors.PieceNotExists();
        }
    }

    function _requireOwnerOfPiece(
        bytes32 _matchEntity,
        bytes32 _entity,
        address _owner
    ) internal view {
        if (!isOwnedByAddress(_matchEntity, _entity, _owner)) {
            revert Errors.PieceNotOwned();
        }
    }

    function _requireCoordinatesAreNotOccupied(
        bytes32 _matchEntity,
        uint32 _x,
        uint32 _y
    ) internal view {
        if (isPositionOccupied(_matchEntity, _x, _y)) {
            revert Errors.PositionOccupied();
        }
    }
}
