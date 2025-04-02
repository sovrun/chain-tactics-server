//SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

library LibEntity {
    function toPlayerEntity(address addrs) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addrs)));
    }

    function entityToAddress(bytes32 entity) internal pure returns (address) {
        return address(uint160(uint256(entity)));
    }

    function toQueueEntity(
        bytes32 boardEntity,
        bytes32 modeEntity
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(boardEntity, modeEntity));
    }
}
