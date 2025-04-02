import { defineWorld } from '@latticexyz/world'

/**
 * MatchStatusTypes:
 *
 * None => uint8(0)
 * None is when the match is not in any state
 *
 * Pending => uint8(1)
 * Waiting is when the match is waiting for players to join
 *
 * Preparing => uint8(2)
 * Preparing is when the match is ready to start and players are setting up their pieces
 *
 * Active => uint8(3)
 * Active is when the match is ongoing
 *
 * Finished => uint8(4)
 * Finished is when the match is over
 *
 * Cancelled => uint8(5)
 * Cancelled is when the match is cancelled by the creator
 *
 *
 * MatchPlayerStatusTypes:
 *
 * None => uint8(0)
 * Waiting => uint8(1)
 * Matched => uint8(2)
 * Ready => uint8(3)
 *
 *
 * SpawnStatusTypes:
 * @note discuss this in the future. Maybe, we can optimize this more
 *
 * None => uint8(0)
 * LockCommitBuying => uint8(1)
 * RevealBuying => uint8(2)
 * LockRevealBuying => uint8(3)
 * CommitSpawning => uint8(4)
 * LockCommitSpawning => uint8(5)
 * RevealSpawning => uint8(6)
 * LockRevealSpawning => uint8(7)
 * Ready => uint8(8)
 **/

export default defineWorld({
  namespace: 'tacticsWar',
  tables: {
    /**
     * Records the board used to play the game
     */
    BoardConfig: {
      key: ['boardEntity'],
      schema: {
        boardEntity: 'bytes32',
        rows: 'uint256',
        columns: 'uint256',
      },
    },
    /**
     * Records the game mode of the match
     */
    GameMode: {
      key: ['gameModeEntity'],
      schema: {
        gameModeEntity: 'bytes32',
        /**
         * Game mode where players take turns moving their pieces
         */
        totalTurn: 'uint256', // when set to zero, game is infinite
        /**
         * Game mode where time is decremented for each player's turn, when runs out player loses
         */
        playerTimeDuration: 'uint256',
        /**
         * Game mode where players take turns moving their pieces and incrementing time,
         * when time runs it skips the player's turn, This is only applicable if totalTurn is zero
         */
        turnTimeIncrement: 'uint256', // time increment per player turn
        /**
         * Preparation time for players to set up their pieces
         */
        prepTime: 'uint256',
      },
    },
    /**
     * MatchEntityCounter serve as a counter for the match entity
     */
    MatchEntityCounter: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        entityCounter: 'uint256',
      },
    },
    /**
     * MatchConfig tracks all the matches that are created by players
     */
    MatchConfig: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        // BoardConfig Entity ID
        boardEntity: 'bytes32',
        // GameMode Entity ID
        gameModeEntity: 'bytes32',
        // Creator of the match
        createdBy: 'address',
        // Number of players before start
        playerCount: 'uint256',
        // Determine if the match is public or private
        isPrivate: 'bool',
      },
    },
    /**
     * MatchStatus tracks the status of the match
     */
    MatchStatus: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        value: 'uint8',
      },
    },
    /**
     * Preparation time for players to set up their pieces
     */
    MatchPreparationTime: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        value: 'uint256',
      },
    },
    /**
     * MatchPool tracks all the matches that are waiting for players
     */
    // MatchPool: {
    //   key: ['boardEntity', 'gameModeEntity'],
    //   schema: {
    //     boardEntity: 'bytes32',
    //     gameModeEntity: 'bytes32',
    //     matchEntity: 'bytes32',
    //   },
    // },
    MatchPool: {
      key: ['queueEntity'],
      schema: {
        queueEntity: 'bytes32',
        players: 'bytes32[]',
      },
    },

    // Tracks the number of players on particular match based on the matchEntity
    // TODO: [future changes] this return the playerEntity under LibEntity
    // change this to LibEntity.toPlayerEntity
    MatchPlayers: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        // matchPlayerEntities
        value: 'bytes32[]',
      },
    },
    // Tracks the number of players (playerEntity) in the match
    // This returns the player entities under LibEntity which correspond
    // to the players that are currently in the match
    // TODO: [future changes] this tables will be the replacement for {MatchPlayers}
    PlayersInMatch: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        // playerEntities
        value: 'bytes32[]',
      },
    },
    /**
     * MatchPlayerStatus tracks the status of the player in the match
     * matchEntity => playerEntity => MatchPlayerStatusTypes
     */
    MatchPlayerStatus: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        value: 'uint8',
      },
    },
    /**
     * Tracks if the player surrendered
     */
    MatchPlayerSurrenders: {
      key: ['matchEntity', 'playerEntity'],
      schema: {
        matchEntity: 'bytes32',
        playerEntity: 'bytes32',
        value: 'bool',
      },
    },
    /**
     * Tracks the number of players that surrendered
     */
    MatchSurrenderCount: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        value: 'uint256',
      },
    },
    /**
     * Index for finding the player in the match
     *
     * matchEntity => player address => playerEntity
     */
    MatchPlayer: {
      key: ['matchEntity', 'player'],
      schema: {
        matchEntity: 'bytes32',
        player: 'address',
        value: 'bytes32',
      },
    },
    /**
     * Records the winner of the match
     */
    MatchWinner: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        value: 'bytes32',
      },
    },
    // @todo if timers are exceeded, do we want to call auto or independent function to determine who will win the match
    /**
     * matchDefaultWinner tracks the tentative winner
     * we populate this when all players made their first and succeeding moves
     * matchEntity => player entity
     */
    MatchDefaultWinner: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        value: 'bytes32',
      },
    },
    /**
     * Tag entity as player
     */
    Player: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        value: 'bool',
      },
    },
    // Tracks the current player match
    // Player generated by converting address to bytes32 (See utils/MatchEntityUtils.sol::playerToEntity)
    PlayerStatus: {
      key: ['playerEntity'],
      schema: {
        playerEntity: 'bytes32',
        matchEntity: 'bytes32',
        matchPlayerEntity: 'bytes32',
        status: 'uint8',
      },
    },
    // TODO: Remove {PlayerQueue} when we transition to off-chain solution
    // Tracks player queueEntity
    PlayerQueue: {
      key: ['playerEntity'],
      schema: {
        playerEntity: 'bytes32',
        value: 'bytes32',
      },
    },
    // Tracks the player displayed IGN
    PlayerInGameName: {
      key: ['playerEntity'],
      schema: {
        playerEntity: 'bytes32',
        value: 'string',
      },
    },
    /**
     * Records the status of player when buying and spawning pieces
     * matchEntity => playerEntity => SpawnStatusTypes
     */
    SpawnStatus: {
      key: ['matchEntity', 'playerEntity'],
      schema: {
        matchEntity: 'bytes32',
        playerEntity: 'bytes32',
        value: 'uint8',
      },
    },
    /**
     * Records the enconded hash a player commits for buy/spawn
     */
    Commit: {
      key: ['matchEntity', 'playerEntity'],
      schema: {
        matchEntity: 'bytes32',
        playerEntity: 'bytes32',
        commitHashes: 'bytes32', // hash of pieceType and random nonce
      },
    },
    /**
     * Tracks the pieces bought by player and current gold balance
     * Player => entity
     */
    Inventory: {
      key: ['matchEntity', 'playerEntity'],
      schema: {
        matchEntity: 'bytes32',
        playerEntity: 'bytes32',
        balance: 'uint256',
        pieces: 'bytes32[]',
      },
    },
    /**
     * Tag entity as primary piece or fortress
     */
    PrimaryPiece: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        value: 'bool',
      },
    },
    /**
     * Tracks the type of piece
     * value => piece type
     */
    Piece: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        value: 'uint256',
      },
    },
    /**
     * Records the combat status of an entity
     */
    Battle: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        health: 'uint256',
        damage: 'uint256',
        attackType: 'uint256',
        range: 'uint256',
        blindspot: 'uint256',
      },
    },
    /**
     * Records the movement capability of an entity
     */
    Movement: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        value: 'uint256',
      },
    },
    /**
     * Records the owner of the entity
     */
    OwnedBy: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        value: 'bytes32', // player entity
      },
    },
    /**
     * Records the movement of the entity on the board
     */
    Position: {
      key: ['matchEntity', 'entity'],
      schema: {
        matchEntity: 'bytes32',
        entity: 'bytes32',
        x: 'uint32',
        y: 'uint32',
      },
    },
    /**
     * Reverse lookup for Position
     */
    EntityAtPosition: {
      key: ['matchEntity', 'x', 'y'],
      schema: {
        matchEntity: 'bytes32',
        x: 'uint32',
        y: 'uint32',
        value: 'bytes32',
      },
    },
    /**
     * currentPlayerIndex tracks the turn of player
     * matchEntity => player index
     */
    ActivePlayer: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        playerIndex: 'uint256',
        timestamp: 'uint256', // this acts as the start time
      },
    },
    /**
     * Records the actions of players when moving/attacking/skipping turns
     *
     **/
    ActionStatus: {
      key: ['matchEntity', 'playerEntity'],
      schema: {
        matchEntity: 'bytes32',
        playerEntity: 'bytes32',
        selectedPiece: 'bytes32',
        movesExecuted: 'uint256',
        battlesExecuted: 'uint256',
      },
    },
    /*
     * Records the last attack happen on an entity
     */
    LastAttackCommited: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        targetPieceEntity: 'bytes32',
        attackerPieceEntity: 'bytes32',
        attackerPlayerEntity: 'bytes32',
        attackerPlayerAddress: 'address',
        targetPieceCurrentHealth: 'uint256',
        timestamp: 'uint256', // this acts as when the attack occurred
      },
    },
    /*
     * Records the last attack happen on an entity
     */
    LastMoveCommited: {
      key: ['matchEntity'],
      schema: {
        matchEntity: 'bytes32',
        pieceEntity: 'bytes32',
        playerEntity: 'bytes32',
        playerAddress: 'address',
        x: 'uint32',
        y: 'uint32',
        timestamp: 'uint256',
      },
    },
  },
})
