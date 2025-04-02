// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Inventory } from "../codegen/tables/Inventory.sol";

library LibInventory {
    function setPlayerInventory(
        bytes32 _matchEntity,
        bytes32 _playerEntity,
        uint256 _balance,
        bytes32[] memory _entities
    ) internal {
        Inventory.set(_matchEntity, _playerEntity, _balance, _entities);
    }

    function setInventory(
        bytes32 _matchEntity,
        bytes32 _playerEntity,
        bytes32 _entity,
        uint256 _balance
    ) internal {
        Inventory.setBalance(_matchEntity, _playerEntity, _balance);
        Inventory.pushPieces(_matchEntity, _playerEntity, _entity);
    }

    function setInventoryBalance(
        bytes32 _matchEntity,
        bytes32 _playerEntity,
        uint256 _balance
    ) internal {
        Inventory.setBalance(_matchEntity, _playerEntity, _balance);
    }
}
