// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../../Base.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";

import { TTW_NAMESPACES, TURN_SYSTEM } from "src/common/constants.sol";

import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { ActivePlayer, ActivePlayerData } from "src/codegen/tables/ActivePlayer.sol";

import { createMatchEntity, createPlayerEntity, createPieceEntity, createFortress } from "src/utils/MatchEntityUtils.sol";

import { ITurnSystem } from "src/systems/interfaces/ITurnSystem.sol";

contract BaseTurnSystem_Test is Base_Test {
    using SystemIds for bytes14;

    bytes32 internal _matchEntity;
    bytes32 internal _playerEntityAlice;
    bytes32 internal _playerEntityEve;
    bytes32 internal _entityAlice;
    bytes32 internal _entityEve;
    bytes32 internal _emptyEntity;
    uint256 internal _movesAllowed;
    uint256 internal _battlesAllowed;

    function _initializeVariables() internal {
        _matchEntity = createMatchEntity(keccak256("MatchEntity"));
        _playerEntityAlice = createPlayerEntity(_matchEntity, users.alice);
        _playerEntityEve = createPlayerEntity(_matchEntity, users.eve);

        (_entityAlice, ) = createPieceEntity(_matchEntity, users.alice, 2);
        (_entityEve, ) = createPieceEntity(_matchEntity, users.eve, 2);

        _emptyEntity = bytes32(0);

        _movesAllowed = 1;
        _battlesAllowed = 1;
    }

    function _createMatchPlayers() internal {
        MatchPlayer.set(_matchEntity, users.alice, _playerEntityAlice);
        MatchPlayer.set(_matchEntity, users.eve, _playerEntityEve);
        MatchPlayers.push(_matchEntity, _playerEntityAlice);
        MatchPlayers.push(_matchEntity, _playerEntityEve);
    }

    function _createActivePlayer() internal {
        ActivePlayer.set(_matchEntity, 0, block.timestamp);
    }

    function setUp() public override {
        Base_Test.setUp();

        changePrankToMudAdmin();
        _initializeVariables();
        _createMatchPlayers();
        _createActivePlayer();
    }

    function _turnSystemId() internal pure returns (ResourceId) {
        return TTW_NAMESPACES.turnSystem();
    }

    function endTurn(bytes32 matchEntity) public {
        world.call(
            _turnSystemId(),
            abi.encodeCall(ITurnSystem.endTurn, (matchEntity))
        );
    }

    function surrender(bytes32 matchEntity) public {
        world.call(
            _turnSystemId(),
            abi.encodeCall(ITurnSystem.surrender, (matchEntity))
        );
    }
}
