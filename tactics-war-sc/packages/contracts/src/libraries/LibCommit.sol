// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Commit } from "../codegen/tables/Commit.sol";

library LibCommit {
    function setCommit(
        bytes32 _matchEntity,
        bytes32 _playerEntity,
        bytes32 _commitHash
    ) internal {
        Commit.set(_matchEntity, _playerEntity, _commitHash);
    }
}
