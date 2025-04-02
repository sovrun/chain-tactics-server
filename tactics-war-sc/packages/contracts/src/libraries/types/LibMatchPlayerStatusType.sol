// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { MatchPlayerStatusTypes } from "../../common/types.sol";

library LibMatchPlayerStatusType {
    function toUint8(
        MatchPlayerStatusTypes status
    ) internal pure returns (uint8) {
        return uint8(status);
    }

    function toMatchPlayerStatusTypes(
        uint8 value
    ) internal pure returns (MatchPlayerStatusTypes) {
        require(
            value <= uint8(MatchPlayerStatusTypes.Ready),
            "LibMatchPlayerStatusType: Invalid value"
        );
        return MatchPlayerStatusTypes(value);
    }

    function isPlayerReady(
        MatchPlayerStatusTypes status
    ) internal pure returns (bool) {
        return status == MatchPlayerStatusTypes.Ready;
    }

    function isPlayerWaiting(
        MatchPlayerStatusTypes status
    ) internal pure returns (bool) {
        return status == MatchPlayerStatusTypes.Waiting;
    }

    function isPlayerInMatch(
        MatchPlayerStatusTypes status
    ) internal pure returns (bool) {
        return status == MatchPlayerStatusTypes.Matched;
    }
}
