// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

interface IBuySystem {
    function commitBuy(bytes32 _commitHash, bytes32 _matchEntity) external;

    function revealBuy(
        bytes32 _matchEntity,
        uint256[] memory _pieceTypes,
        bytes32 _secret
    ) external;
}
