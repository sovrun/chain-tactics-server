// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

//** NAMESPACES */

bytes14 constant TTW_NAMESPACES = "tacticsWar";

//** SYSTEM */

bytes16 constant MATCH_SYSTEM = "MatchSystem";

bytes16 constant BUY_SYSTEM = "BuySystem";

bytes16 constant SPAWN_SYSTEM = "SpawnSystem";

bytes16 constant MOVE_SYSTEM = "MoveSystem";

bytes16 constant COMBAT_SYSTEM = "CombatSystem";

bytes16 constant TURN_SYSTEM = "TurnSystem";

bytes16 constant PLAYER_SYSTEM = "PlayerSystem";

//** VARIABLES */

uint256 constant BUY_PREP_TIME = 2 minutes;

uint256 constant SPAWN_PREP_TIME = 2 minutes;

uint256 constant TURN_TIMER = 60 seconds;

uint256 constant TURN_DURATION = 60 seconds;

uint256 constant CLIENT_TRIGGER_DELAY = 27 seconds;

uint256 constant GOLD_BALANCE = 10;

uint256 constant NUMBER_OF_MOVES_ALLOWED = 1;

uint256 constant NUMBER_OF_BATTLES_ALLOWED = 1;

uint256 constant NUMBER_OF_ATTACKS_ALLOWED = 1;
