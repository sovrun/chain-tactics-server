// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { Position, PositionData } from "../codegen/tables/Position.sol";
import { SpawnStatus } from "../codegen/tables/SpawnStatus.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { PlayerInGameName } from "../codegen/tables/PlayerInGameName.sol";

import { getPiecesOwnedByPlayer, playerFromAddress } from "../libraries/LibUtils.sol";
import { PieceLibrary } from "../libraries/PieceLibrary.sol";
import { LibEntity } from "../libraries/LibEntity.sol";

import { isCurrentPlayerTurn } from "../utils/TurnUtils.sol";

contract ViewSystem is System {
    using LibEntity for address;

    /**
     * @notice Retrieves the entities of pieces owned by a specific player in a match.
     * @param matchEntity The identifier of the match in which the pieces are located.
     * @param playerEntity The identifier of the player whose pieces are being retrieved.
     * @dev This function returns an array of `bytes32` representing the piece entities owned by the specified player in the given match.
     */
    function getPieceEntities(
        bytes32 matchEntity,
        bytes32 playerEntity
    ) public view returns (bytes32[] memory pieceEntities) {
        pieceEntities = getPiecesOwnedByPlayer(matchEntity, playerEntity);
    }

    /**
     * @notice Retrieves the entities of pieces owned by a specific player in a match.
     * @param matchEntity The identifier of the match in which the pieces are located.
     * @dev This function returns an array of `bytes32` representing the piece entities owned by the specified player in the given match.
     */
    function getPieceEntitiesByAddress(
        bytes32 matchEntity
    ) public view returns (bytes32[] memory pieceEntities) {
        bytes32 playerEntity = playerFromAddress(matchEntity, _msgSender());
        pieceEntities = getPiecesOwnedByPlayer(matchEntity, playerEntity);
    }

    /**
     * @notice Retrieve a piece based on its type.
     * @param pieceType The integer representation of the piece type.
     * @dev This function returns a `Piece` structure from the `PieceLibrary` based on the provided piece type.
     * Example: getPiece(1) returns the `Piece` structure for the specified piece type.
     */
    function getPiece(
        uint pieceType
    ) public pure returns (PieceLibrary.Piece memory) {
        return PieceLibrary.getPiece(PieceLibrary.PieceType(pieceType));
    }

    /**
     * @notice Generates a commit hash from given piece types and secret using the keccak256 hashing algorithm.
     * @param _pieceTypes An array of uint256 integers representing different types of game pieces.
     * @param _secret A bytes32 value representing as salt associated with each piece type.
     * @return commitHash A bytes32 value representing the generated hash.
     */
    function generateBuyCommitHash(
        uint256[] memory _pieceTypes,
        bytes32 _secret
    ) public pure returns (bytes32 commitHash) {
        commitHash = keccak256(abi.encode(_pieceTypes, _secret));
    }

    /**
     * @notice Generates a spawn commit hash from given coordinates, piece entities, and secret using the keccak256 hashing algorithm.
     * @param _coordinates An array of PositionData structures representing the coordinates of the pieces.
     * @param _pieceEntities An array of bytes32 values representing different piece entities.
     * @param _secret A bytes32 value representing salt associated with each piece entity.
     * @return commitHash A bytes32 value representing the generated hash.
     */
    function generateSpawnCommitHash(
        PositionData[] memory _coordinates,
        bytes32[] memory _pieceEntities,
        bytes32 _secret
    ) public pure returns (bytes32 commitHash) {
        commitHash = keccak256(
            abi.encode(_pieceEntities, _coordinates, _secret)
        );
    }

    /**
     * @notice Retrieves the spawn status for a specific player in a match
     * @param _matchEntity The entity representing the match
     * @param _playerEntity The entity representing the player
     * @dev Uses SpawnStatus to get the current status for the given player and match entities
     */
    function getSpawnStatus(
        bytes32 _matchEntity,
        bytes32 _playerEntity
    ) public view returns (uint8 value) {
        value = SpawnStatus.getValue(_matchEntity, _playerEntity);
    }

    /**
     * @notice Retrieves the spawn status for the current message sender based on the match
     * @param _matchEntity The entity representing the match
     * @dev Derives the player entity from the sender's address and the match entity,
     *      then retrieves the spawn status using SpawnStatus.
     */
    function getSpawnStatusByAddress(
        bytes32 _matchEntity
    ) public view returns (uint8 value) {
        bytes32 playerEntity = playerFromAddress(_matchEntity, _msgSender());
        value = SpawnStatus.getValue(_matchEntity, playerEntity);
    }

    /**
     * @notice Retrieves the list of players for a given match entity.
     * @param _matchEntity The unique identifier for the match.
     * @return players An array of player entities associated with the match.
     * @dev This function fetches the player entities from the MatchPlayers mapping using the provided match entity.
     */
    function getMatchPlayers(
        bytes32 _matchEntity
    ) public view returns (bytes32[] memory players) {
        players = MatchPlayers.get(_matchEntity);
    }

    /**
     * @notice Retrieves the name of the current user
     * @return name A string representing the name of the user.
     * @dev This function uses the player's entity to access the PlayerInGameName mapping to retrieve the name of the current user.
     */
    function getPlayerInGameName() public view returns (string memory name) {
        name = PlayerInGameName.getValue(_msgSender().toPlayerEntity());
    }

    /**
     * @notice Retrieves if the player is the active player
     * @return _matchEntity The unique identifier for the match.
     * @param _player The address of the player.
     * @dev This function checks if the player is the current player in the match using the isCurrentPlayerTurn function.
     */
    function isActivePlayer(
        bytes32 _matchEntity,
        address _player
    ) public view returns (bool) {
        return isCurrentPlayerTurn(_matchEntity, _player);
    }
}
