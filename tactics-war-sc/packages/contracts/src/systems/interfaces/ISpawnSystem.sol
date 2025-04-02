// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PositionData } from "src/codegen/tables/Position.sol";

interface ISpawnSystem {
    function commitSpawn(bytes32 _commitHash, bytes32 _matchEntity) external;

    function revealSpawn(
        bytes32 _matchEntity,
        PositionData[] calldata _coordinates,
        bytes32[] calldata _pieceEntities,
        bytes32 _secret
    ) external;
}
