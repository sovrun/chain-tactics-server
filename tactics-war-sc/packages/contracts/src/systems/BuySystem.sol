// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { MatchPlayer } from "../codegen/tables/MatchPlayer.sol";
import { SpawnStatus } from "../codegen/tables/SpawnStatus.sol";
import { Position } from "../codegen/tables/Position.sol";
import { Inventory, InventoryData } from "../codegen/tables/Inventory.sol";
import { Piece } from "../codegen/tables/Piece.sol";
import { Commit } from "../codegen/tables/Commit.sol";
import { PrimaryPiece } from "../codegen/tables/PrimaryPiece.sol";

import { LibSpawn } from "../libraries/LibSpawn.sol";
import { LibMatch } from "../libraries/LibMatch.sol";
import { LibBattle } from "../libraries/LibBattle.sol";
import { LibMovement } from "../libraries/LibMovement.sol";
import { LibOwnedBy } from "../libraries/LibOwnedBy.sol";
import { LibCommit } from "../libraries/LibCommit.sol";
import { LibInventory } from "../libraries/LibInventory.sol";

import { BaseMatch } from "./base/BaseMatch.sol";
import { BaseUnit } from "./base/BaseUnit.sol";

import { PieceLibrary } from "../libraries/PieceLibrary.sol";
import { LibPieceType } from "../libraries/types/LibPieceType.sol";
import { LibSpawnStatusType } from "../libraries/types/LibSpawnStatusType.sol";
import { playerFromAddress } from "../libraries/LibUtils.sol";
import { SpawnStatusTypes, PieceType } from "../common/types.sol";
import { Errors } from "../common/Errors.sol";
import { createPieceEntity, createFortress, createMatchEntity } from "../utils/MatchEntityUtils.sol";

import { IBuySystem } from "./interfaces/IBuySystem.sol";

contract BuySystem is System, BaseMatch, BaseUnit, IBuySystem {
    using PieceLibrary for PieceLibrary.PieceType;

    using LibPieceType for PieceType;
    using LibPieceType for uint256;

    using LibSpawnStatusType for SpawnStatusTypes;
    using LibSpawnStatusType for uint8;

    function commitBuy(
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

        _requireSpawnStatusToBeNone(_matchEntity, matchPlayerEntity);

        LibCommit.setCommit(_matchEntity, matchPlayerEntity, _commitHash);
        LibSpawn.setSpawnStatus(
            _matchEntity,
            matchPlayerEntity,
            SpawnStatusTypes.LockCommitBuying
        );
        _checkSpawnStatusAndProceed(
            _matchEntity,
            SpawnStatusTypes.LockCommitBuying
        );
    }

    function revealBuy(
        bytes32 _matchEntity,
        uint256[] memory _pieceTypes,
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
            _pieceTypes,
            _secret
        );

        bytes32[] memory pieceEntities = new bytes32[](_pieceTypes.length);
        uint256 totalGoldCost = 0;
        uint256 entityCounter = 0;

        InventoryData memory playerInventory = Inventory.get(
            _matchEntity,
            matchPlayerEntity
        );

        for (; entityCounter < _pieceTypes.length; entityCounter++) {
            uint256 pieceType = _pieceTypes[entityCounter];

            _requirePieceIsNotFortress(pieceType.toPieceTypes());

            (
                bytes32 pieceEntity,
                PieceLibrary.Piece memory piece
            ) = createPieceEntity(_matchEntity, _msgSender(), pieceType);

            _requirePlayerHasEnoughGold(
                playerInventory.balance,
                totalGoldCost + piece.cost
            );

            pieceEntities[entityCounter] = pieceEntity;
            totalGoldCost += piece.cost;
        }

        LibInventory.setPlayerInventory(
            _matchEntity,
            matchPlayerEntity,
            playerInventory.balance - totalGoldCost,
            pieceEntities
        );

        LibSpawn.setSpawnStatus(
            _matchEntity,
            matchPlayerEntity,
            SpawnStatusTypes.LockRevealBuying
        );

        _checkSpawnStatusAndProceed(
            _matchEntity,
            SpawnStatusTypes.LockRevealBuying
        );
    }

    function setPlayerInventory(
        bytes32 _matchEntity,
        bytes32 _playerEntity,
        bytes32 _pieceEntity,
        uint256 _balance
    ) internal {
        LibInventory.setInventory(
            _matchEntity,
            _playerEntity,
            _pieceEntity,
            _balance
        );
    }

    function _requireSpawnStatusToBeNone(
        bytes32 _matchEntity,
        bytes32 _matchPlayerEntity
    ) public view {
        if (
            SpawnStatus
                .get(_matchEntity, _matchPlayerEntity)
                .toSpawnStatusTypes()
                .isNotNone()
        ) {
            revert Errors.IncorrectCommitStatus();
        }
    }

    function _requirePlayerHasEnoughGold(
        uint256 _gold,
        uint256 _cost
    ) internal pure {
        if (_gold < _cost) {
            revert Errors.NotEnoughGold();
        }
    }

    function _requireEncodedHashIsEqualToCommitedHash(
        bytes32 _matchEntity,
        bytes32 _matchPlayerEntity,
        uint256[] memory _pieceTypes,
        bytes32 _secret
    ) internal view {
        bytes32 commitHash = Commit.get(_matchEntity, _matchPlayerEntity);
        // Generate the combined hash from the piece types and secret
        bytes32 encodedCommitHash = keccak256(abi.encode(_pieceTypes, _secret));

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
                .isNotRevealBuying()
        ) {
            revert Errors.IncorrectRevealStatus();
        }
    }

    function _requirePieceIsNotFortress(PieceType _pieceType) internal pure {
        if (_pieceType.isFortress()) {
            revert Errors.PieceNotAllowedToBuy();
        }
    }

    // @note this function needs to be refactored using `createFortress()` of `MatchEntityUtils`
    /// @dev did not do right now since I have to refactored this function to accept `_msgSender()`
    function _distributePrimaryPiece(
        bytes32 _matchEntity,
        bytes32 _playerEntity
    ) internal override {
        (
            uint256 movement,
            uint256 health,
            uint256 damage,
            uint256 range,
            uint256 blindspot,
            uint256 attackType
        ) = LibSpawn.getFortressDetails();
        bytes32 pieceEntity = createMatchEntity(_matchEntity);

        Piece.set(_matchEntity, pieceEntity, 1);
        LibBattle.setBattle(
            _matchEntity,
            pieceEntity,
            health,
            damage,
            attackType,
            range,
            blindspot
        );
        Inventory.pushPieces(_matchEntity, _playerEntity, pieceEntity);
        LibMovement.setMovement(_matchEntity, pieceEntity, movement);
        LibOwnedBy.setOwnedBy(_matchEntity, pieceEntity, _playerEntity);
        PrimaryPiece.setValue(_matchEntity, pieceEntity, true);
    }
}
