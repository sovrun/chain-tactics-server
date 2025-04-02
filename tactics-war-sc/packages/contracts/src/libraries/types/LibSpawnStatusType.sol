// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { MatchPreparationTime } from "../../codegen/tables/MatchPreparationTime.sol";
import { SpawnStatusTypes } from "../../common/types.sol";

library LibSpawnStatusType {
    function toUint8(SpawnStatusTypes status) internal pure returns (uint8) {
        return uint8(status);
    }

    function toSpawnStatusTypes(
        uint8 value
    ) internal pure returns (SpawnStatusTypes) {
        require(
            value <= uint8(SpawnStatusTypes.Ready),
            "LibSpawnStatusType: Invalid value"
        );
        return SpawnStatusTypes(value);
    }

    function isNone(SpawnStatusTypes status) internal pure returns (bool) {
        return status == SpawnStatusTypes.None;
    }

    function isLockCommitBuying(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status == SpawnStatusTypes.LockCommitBuying;
    }

    function isRevealBuying(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status == SpawnStatusTypes.RevealBuying;
    }

    function isLockRevealBuying(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status == SpawnStatusTypes.LockRevealBuying;
    }

    function isCommitSpawning(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status == SpawnStatusTypes.CommitSpawning;
    }

    function isLockCommitSpawning(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status == SpawnStatusTypes.LockCommitSpawning;
    }

    function isLockRevealSpawning(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status == SpawnStatusTypes.LockRevealSpawning;
    }

    function isReady(SpawnStatusTypes status) internal pure returns (bool) {
        return status > SpawnStatusTypes.LockCommitSpawning;
    }

    function isNotNone(SpawnStatusTypes status) internal pure returns (bool) {
        return status != SpawnStatusTypes.None;
    }

    function isNotRevealBuying(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status != SpawnStatusTypes.RevealBuying;
    }

    function isNotCommitSpawning(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status != SpawnStatusTypes.CommitSpawning;
    }

    function isNotRevealSpawning(
        SpawnStatusTypes status
    ) internal pure returns (bool) {
        return status != SpawnStatusTypes.RevealSpawning;
    }

    function isNotReady(SpawnStatusTypes status) internal pure returns (bool) {
        // assuming player did not reveal their spawn positions
        // this is the case when they are still in the buying phase
        // and haven't revealed their spawn positions yet
        return status < SpawnStatusTypes.LockRevealSpawning;
    }

    function isOpponentActive(
        SpawnStatusTypes status,
        bytes32 matchEntity,
        SpawnStatusTypes opponentStatus
    ) internal view returns (bool) {
        uint256 preparationTimestamp = MatchPreparationTime.get(matchEntity);
        return
            block.timestamp > preparationTimestamp && opponentStatus >= status;
    }
}
