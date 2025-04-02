// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Errors } from "../common/Errors.sol";

import { PlayerInGameName } from "../codegen/tables/PlayerInGameName.sol";

import { LibEntity } from "../libraries/LibEntity.sol";

contract PlayerSystem is System {
    using LibEntity for address;

    modifier onlyValidName(string calldata name) {
        if (bytes(name).length == 0) {
            revert Errors.EmptyPlayerName();
        }
        _;
    }

    function setPlayerName(string calldata name) public onlyValidName(name) {
        PlayerInGameName.setValue(_msgSender().toPlayerEntity(), name);
    }
}
