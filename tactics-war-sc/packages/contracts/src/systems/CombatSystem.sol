// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { SystemIds } from "../libraries/SystemIds.sol";

import { BaseMatch } from "./base/BaseMatch.sol";
import { BaseTurn } from "./base/BaseTurn.sol";

import { Position, PositionData } from "../codegen/tables/Position.sol";

import { IWorld } from "../codegen/world/IWorld.sol";
import { playerFromAddress, pieceEntityCombat, isOwnedByAddress, isPositionOccupied, getEntityAtPosition, getEntityPosition } from "../libraries/LibUtils.sol";
import { resetPlayerActions } from "../utils/GameUtils.sol";

import { LibUnitCombat } from "../libraries/LibUnitCombat.sol";
import { LibMatchWinner } from "../libraries/LibMatchWinner.sol";
import { LibAction } from "../libraries/LibAction.sol";
import { LibTurn } from "../libraries/LibTurn.sol";

import { isActionConsumed, isActionValid } from "../utils/ActionUtils.sol";
import { isTargetValid, isFortressDestroyed } from "../utils/CombatUtils.sol";

import { TTW_NAMESPACES } from "../common/constants.sol";
import { Errors } from "../common/Errors.sol";

import { ICombatSystem } from "./interfaces/ICombatSystem.sol";
import { MoveSystem } from "./MoveSystem.sol";

contract CombatSystem is System, BaseTurn, BaseMatch, ICombatSystem {
    using SystemIds for bytes14;
    using LibUnitCombat for bytes32;
    using LibMatchWinner for bytes32;
    using LibAction for bytes32;
    using LibTurn for bytes32;

    function moveOrAttack(
        bytes32 _matchEntity,
        bytes32 _entity,
        PositionData[] memory path
    )
        public
        override
        onlyActiveMatch(_matchEntity)
        onlyCurrentPlayer(_matchEntity, _msgSender())
    {
        PositionData memory target = path[path.length - 1];
        if (isPositionOccupied(_matchEntity, target.x, target.y)) {
            _attack(_matchEntity, _entity, target.x, target.y);
        } else {
            _move(_matchEntity, _entity, path);
        }
    }

    function attack(
        bytes32 _matchEntity,
        bytes32 _entity,
        bytes32 _target
    )
        public
        override
        onlyActiveMatch(_matchEntity)
        onlyCurrentPlayer(_matchEntity, _msgSender())
    {
        (uint32 targetX, uint32 targetY) = getEntityPosition(
            _matchEntity,
            _target
        );
        _attack(_matchEntity, _entity, targetX, targetY);
    }

    function _attack(
        bytes32 _matchEntity,
        bytes32 _entity,
        uint32 _targetX,
        uint32 _targetY
    ) internal {
        _requireValidNumberOfAttacks(_matchEntity, _entity);
        _requireOwnerOfPiece(_matchEntity, _entity);
        _requireIsValidAttack(_matchEntity, _entity, _targetX, _targetY);

        bytes32 targetEntity = getEntityAtPosition(
            _matchEntity,
            _targetX,
            _targetY
        );
        LibUnitCombat.attack(_matchEntity, _entity, targetEntity, _msgSender());

        if (isFortressDestroyed(_matchEntity, targetEntity)) {
            LibMatchWinner.setWinner(_matchEntity, _msgSender());
        }

        LibAction.executePlayerAction(
            _matchEntity,
            _msgSender(),
            _entity,
            LibAction.ActionType.ATTACK
        );
    }

    function _move(
        bytes32 _matchEntity,
        bytes32 _entity,
        PositionData[] memory _path
    ) internal {
        IWorld(_world()).call(
            TTW_NAMESPACES.moveSystem(),
            abi.encodeCall(MoveSystem.move, (_matchEntity, _entity, _path))
        );
    }

    function _requireValidNumberOfAttacks(
        bytes32 _matchEntity,
        bytes32 _entity
    ) internal view {
        bool isValid = isActionValid(
            _matchEntity,
            _msgSender(),
            _entity,
            LibAction.ActionType.ATTACK
        );
        if (!isValid) {
            revert Errors.InvalidAction();
        }
    }

    function _requireOwnerOfPiece(
        bytes32 _matchEntity,
        bytes32 _entity
    ) internal view {
        if (!isOwnedByAddress(_matchEntity, _entity, _msgSender())) {
            revert Errors.PieceNotOwned();
        }
    }

    function _requireIsValidAttack(
        bytes32 _matchEntity,
        bytes32 _entity,
        uint32 _targetX,
        uint32 _targetY
    ) internal view {
        bool isValid = isTargetValid(
            _matchEntity,
            _msgSender(),
            _entity,
            _targetX,
            _targetY
        );
        if (!isValid) {
            revert Errors.InvalidAttack();
        }
    }
}
