// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BoardConfigData, BoardConfig } from "../codegen/tables/BoardConfig.sol";
import { PositionData } from "../codegen/tables/Position.sol";
import { MatchPlayers } from "../codegen/tables/MatchPlayers.sol";
import { Commit } from "../codegen/tables/Commit.sol";
import { SpawnStatus } from "../codegen/tables/SpawnStatus.sol";
import { SpawnStatusTypes } from "../common/types.sol";

library LibSpawn {
    // @todo remove on v2
    function getFortressDetails()
        internal
        pure
        returns (
            uint256 movement,
            uint256 health,
            uint256 damage,
            uint256 range,
            uint256 blindspot,
            uint256 attackType
        )
    {
        health = 3;
        damage = 1;
        attackType = 1;
        range = 2;
        blindspot = 0;
        movement = 1;
    }

    // @todo remove on v2
    function setSpawnStatus(
        bytes32 _matchEntity,
        bytes32 _playerEntity,
        SpawnStatusTypes _statusType
    ) internal {
        SpawnStatus.set(_matchEntity, _playerEntity, uint8(_statusType));
    }

    function isWithinBoardCoordinates(
        uint32 _x,
        uint32 _y,
        BoardConfigData memory _boardConfigData
    ) internal pure returns (bool) {
        return (_x >= 1 &&
            _x <= uint32(_boardConfigData.rows) &&
            _y >= 1 &&
            _y <= uint32(_boardConfigData.columns));
    }

    function isSpawnableArea(
        bytes32 _matchEntity,
        bytes32 _playerEntity,
        bytes32 _boardEntity,
        PositionData memory _coordinate
    ) internal view returns (bool isValidSpawnArea) {
        bytes32[] memory matchPlayers = MatchPlayers.get(_matchEntity);
        uint256 rows = BoardConfig.getRows(_boardEntity);
        uint256 playerIndex;

        // @note have to specifically configured for two players only
        if (matchPlayers.length == 2) {
            for (uint256 i = 0; i < matchPlayers.length; i++) {
                if (matchPlayers[i] == _playerEntity) {
                    playerIndex = i;
                    break;
                }
            }

            if (playerIndex == 0) {
                // Player 1 (index 0) can spawn on the first 2 ranks
                isValidSpawnArea = (_coordinate.y == 1 || _coordinate.y == 2);
            } else if (playerIndex == 1) {
                // Player 2 (index 1) can spawn on the last 2 ranks
                isValidSpawnArea = (_coordinate.y == rows ||
                    _coordinate.y == rows - 1);
            }
        }
    }

    function isEncodedHashNotEqualToCommitedHash(
        bytes32 matchEntity,
        bytes32 playerEntity,
        bytes32 encodedCommitHash
    ) internal view returns (bool) {
        return encodedCommitHash != Commit.get(matchEntity, playerEntity);
    }
}
