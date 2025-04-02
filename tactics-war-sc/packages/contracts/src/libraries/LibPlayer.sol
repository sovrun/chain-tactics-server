//SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PlayerStatus, PlayerStatusData } from "../codegen/tables/PlayerStatus.sol";

library LibPlayer {
    function toPlayerEntity(address addrs) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addrs)));
    }

    function getPlayerStatus(
        bytes32 playerEntity
    ) internal view returns (PlayerStatusData memory) {
        return PlayerStatus.get(playerEntity);
    }

    function isPlayerInMatch(
        PlayerStatusData memory data
    ) internal pure returns (bool) {
        return data.matchEntity != bytes32(0);
    }
}
