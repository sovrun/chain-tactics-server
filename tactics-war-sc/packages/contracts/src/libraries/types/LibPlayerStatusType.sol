// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { PlayerStatusTypes } from "../../common/types.sol";

library LibPlayerStatusType {
    /// @notice Converts a `PlayerStatusTypes` enum value to its corresponding `uint8` value
    /// @param status The enum value to convert
    /// @return `uint8` representation of the enum value
    function toUint8(PlayerStatusTypes status) internal pure returns (uint8) {
        return uint8(status);
    }

    /// @notice Converts a `uint8` value to its corresponding `PlayerStatusTypes` enum value
    /// @param value The `uint8` value to convert
    /// @return `PlayerStatusTypes` representation of the `uint8` value
    function toPlayerStatusTypes(
        uint8 value
    ) internal pure returns (PlayerStatusTypes) {
        require(
            value <= uint8(PlayerStatusTypes.Playing),
            "LibPlayerStatusType: Invalid value"
        );
        return PlayerStatusTypes(value);
    }

    function isNone(PlayerStatusTypes status) internal pure returns (bool) {
        return status == PlayerStatusTypes.None;
    }

    function isQueueing(PlayerStatusTypes status) internal pure returns (bool) {
        return status == PlayerStatusTypes.Queueing;
    }

    function isPlaying(PlayerStatusTypes status) internal pure returns (bool) {
        return status == PlayerStatusTypes.Playing;
    }
}
