// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PositionData } from "src/codegen/tables/Position.sol";

interface IMoveSystem {
    function move(
        bytes32 _matchEntity,
        bytes32 _entity,
        PositionData[] memory _path
    ) external;
}
