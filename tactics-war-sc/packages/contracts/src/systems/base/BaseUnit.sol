// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MatchPlayers } from "../../codegen/tables/MatchPlayers.sol";
import { MatchStatus } from "../../codegen/tables/MatchStatus.sol";
import { MatchPreparationTime } from "../../codegen/tables/MatchPreparationTime.sol";
import { ActivePlayer, ActivePlayerData } from "../../codegen/tables/ActivePlayer.sol";
import { Commit } from "../../codegen/tables/Commit.sol";
import { SpawnStatus } from "../../codegen/tables/SpawnStatus.sol";
import { LibMatchStatusType } from "../../libraries/types/LibMatchStatusType.sol";
import { recordPlayerActions, resetPlayerActions } from "../../utils/GameUtils.sol";
import { MatchStatusTypes, SpawnStatusTypes } from "../../common/types.sol";
import { Errors } from "../../common/Errors.sol";

import { SPAWN_PREP_TIME, TURN_TIMER, NUMBER_OF_MOVES_ALLOWED, NUMBER_OF_BATTLES_ALLOWED } from "../../common/constants.sol";

contract BaseUnit {
    modifier onlyIfPreparationTimeIsNotOver(bytes32 _matchEntity) {
        uint256 prepTime = MatchPreparationTime.get(_matchEntity);

        if (block.timestamp > prepTime) {
            revert Errors.PreparationTimeOver();
        }
        _;
    }

    modifier commitHashIsNotEmpty(bytes32 commitHash) {
        if (commitHash == 0) {
            revert Errors.NoCommitHash();
        }
        _;
    }

    function _checkSpawnStatusAndProceed(
        bytes32 _matchEntity,
        SpawnStatusTypes _spawnStatus
    ) internal {
        bytes32[] memory playerEntities = MatchPlayers.get(_matchEntity);
        bool allPlayersSameStatus = true;
        bool allPlayersAreReady = false;
        for (uint256 i = 0; i < playerEntities.length; i++) {
            if (
                SpawnStatus.get(_matchEntity, playerEntities[i]) !=
                uint8(_spawnStatus)
            ) {
                allPlayersSameStatus = false;
                break;
            }
        }

        if (allPlayersSameStatus) {
            for (uint256 i = 0; i < playerEntities.length; i++) {
                if (_spawnStatus == SpawnStatusTypes.LockCommitBuying) {
                    SpawnStatus.set(
                        _matchEntity,
                        playerEntities[i],
                        uint8(SpawnStatusTypes.RevealBuying)
                    );
                } else if (_spawnStatus == SpawnStatusTypes.LockRevealBuying) {
                    SpawnStatus.set(
                        _matchEntity,
                        playerEntities[i],
                        uint8(SpawnStatusTypes.CommitSpawning)
                    );

                    // Distribute the piece
                    // send fortresses to player
                    _distributePrimaryPiece(_matchEntity, playerEntities[i]);
                    Commit.deleteRecord(_matchEntity, playerEntities[i]);
                    MatchPreparationTime.set(
                        _matchEntity,
                        block.timestamp + SPAWN_PREP_TIME
                    );
                } else if (
                    _spawnStatus == SpawnStatusTypes.LockCommitSpawning
                ) {
                    SpawnStatus.set(
                        _matchEntity,
                        playerEntities[i],
                        uint8(SpawnStatusTypes.RevealSpawning)
                    );
                } else if (
                    _spawnStatus == SpawnStatusTypes.LockRevealSpawning
                ) {
                    SpawnStatus.set(
                        _matchEntity,
                        playerEntities[i],
                        uint8(SpawnStatusTypes.Ready)
                    );

                    allPlayersAreReady = true;
                }
            }
        }

        if (allPlayersAreReady) {
            // Flip the coin
            _flip(_matchEntity);

            // Change match status set
            MatchStatus.set(_matchEntity, uint8(MatchStatusTypes.Active));

            // Adjust the preparation time so leave function can be called immediately
            MatchPreparationTime.set(_matchEntity, block.timestamp);
        }
    }

    function _flip(bytes32 _matchEntity) internal {
        // Retrieve the list of players in the match.
        bytes32[] memory matchPlayers = MatchPlayers.get(_matchEntity);

        // Ensure that matchPlayers is not empty.
        require(matchPlayers.length > 0, "No players in the match");

        // Generate a pseudo-random seed using block data.
        uint256 randomSeed = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, block.timestamp, msg.sender)
            )
        );

        // Initialize the turn order array with the same length as matchPlayers.
        uint256[] memory turnOrder = new uint256[](matchPlayers.length);

        // Populate turnOrder with sequential indices from 0 to matchPlayers.length - 1.
        for (uint256 i = 0; i < matchPlayers.length; i++) {
            turnOrder[i] = i;
        }

        // Shuffle the turnOrder array using the Fisher-Yates algorithm.
        for (uint256 i = matchPlayers.length - 1; i > 0; i--) {
            // Generate a random index j such that 0 <= j <= i.

            uint256 j = randomSeed % (i + 1);

            // Swap the elements at indices i and j.
            (turnOrder[i], turnOrder[j]) = (turnOrder[j], turnOrder[i]);

            // Update the random seed to ensure the next iteration uses a new random value.
            randomSeed = uint256(keccak256(abi.encodePacked(randomSeed)));
        }

        // Initialize the new match players order
        bytes32[] memory newMatchPlayersOrder = new bytes32[](
            matchPlayers.length
        );

        // Store the shuffled turn order in the TurnOrder mapping.
        for (uint256 i = 0; i < turnOrder.length; i++) {
            newMatchPlayersOrder[i] = matchPlayers[turnOrder[i]];
        }

        MatchPlayers.set(_matchEntity, newMatchPlayersOrder);
        ActivePlayer.set(_matchEntity, 0, block.timestamp);
    }

    function _distributePrimaryPiece(
        bytes32 _matchEntity,
        bytes32 _playerEntity
    ) internal virtual {}
}
