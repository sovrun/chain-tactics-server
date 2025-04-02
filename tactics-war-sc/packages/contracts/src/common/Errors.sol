// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

library Errors {
    /// Error when player in game name is empty string
    error EmptyPlayerName();

    /// Error when player already in existing match
    error PlayerAlreadyInMatch();

    /// Error when not enough players to start match
    error NotEnoughPlayers();

    /// Error when match is not available
    error MatchNotAvailable();

    /// Error when match creator tries to join their own match
    error CreatorCannotJoin();

    /// Error when preparation time over
    error PreparationTimeOver();

    /// Error when player is not in the match
    error PlayerNotInMatch();

    /// Error when match cannot be cancelled
    error MatchCannotBeCancelled();

    // ************** Set Player Ready Errors ************** //

    /// Error when player is already ready in a match
    error PlayerAlreadyReady();

    // ************** Join Queue Match Errors ************** //

    /// Error when player is already in queue
    error PlayerAlreadyInQueue();

    /// Error when player trying to join on queue with ongoing match
    error PlayerHasOngoingMatch();

    error NotAllowedToLeave();

    // ************** Surrender Match Errors ************** //

    // Error when player tried to surrender when already surrendered in the same match
    error PlayerAlreadySurrendered();

    // Error when player tried to surrender on cancelled or finished match
    error MatchIsOver();

    // ************** Leave Match Errors ************** //

    // Errors when calling `leave` when player is not in queue or match
    error NotInQueueOrMatch();

    // ************** Base Match Errors ************** //

    // Error when trying to trigger function that requires the match to be in an active state
    error MatchNotActive();

    // Error when trying to trigger function that requires the match to be in a preparing state
    error MatchNotPreparing();

    // *************** Claim Victory Errors *************** //

    // Error when player preparation time is not over or opponet spawn status greater than caller spawn status
    error OpponentActive();

    // This error is thrown when a player attempts to leave the match
    //  but the opponent has become inactive or idle without completing
    //  the commit and reveal phases during the preparation time.
    error OpponentNotActive();

    // *************** Buy & Spawn Errors ************** //

    // Error when a player has no commit hash
    error NoCommitHash();

    // Error when a player spawn status is not on commit
    error IncorrectCommitStatus();

    // Error when a player spawn status is not on reveal
    error IncorrectRevealStatus();

    // Error when a player sends a different pieces in commit buy and reveal buy
    error InvalidReveal();

    // *************** Buy Errors ************** //

    // Error when a player has not enough gold to buy the pieces
    error NotEnoughGold();

    // Error when a player tries to buy the primary piece (fortress)
    error PieceNotAllowedToBuy();

    // *************** Spawn Errors ************** //

    // Error when player spawn status is none
    error PlayerSpawnStatusNone();

    // Error when the position was already occupied by another piece
    error PositionOccupied();

    // Error when the position you selected to be the spawn area is not designated for you
    error NotInSpawnArea();

    // Error when the chosen position is not allowed to be spawned of
    error CoordinateNotAllowed();

    // *************** Move Errors ************** //

    // Error when player is not the active player
    error NotPlayerTurn(address player);

    // Error when a player tries to move/attack a with different pieces
    error NotSelectedPiece();

    // Error when a player tries to perform a move after the maximum number of moves has been reached
    error ExceededMovesAllowed();

    // Error when a piece does not exist
    error PieceNotExists();

    // Error when a piece does not belong to the player
    error PieceNotOwned();

    // Error when the path is direct diagonal
    error InvalidPath();

    // Error when the distance is greater than the movement of the piece
    error InvalidMove();

    // *************** Combat Errors ************** //

    // Error when attempt to attack is invalid
    error InvalidAttack();

    // Error when action has exceeded the allowed number of attacks
    error InvalidAction();
}
