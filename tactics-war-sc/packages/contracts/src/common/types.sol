// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

enum MatchStatusTypes {
    None,
    Pending,
    Preparing,
    Active,
    Finished,
    Cancelled
}
enum MatchPlayerStatusTypes {
    None,
    Waiting,
    Matched,
    Ready
}
enum SpawnStatusTypes {
    None,
    LockCommitBuying,
    RevealBuying,
    LockRevealBuying,
    CommitSpawning,
    LockCommitSpawning,
    RevealSpawning,
    LockRevealSpawning,
    Ready
}

enum PlayerStatusTypes {
    None, // Player has no status
    Queueing, // Player is in the matchmaking queue
    Playing // Player is currently in a match
}

enum PieceType {
    Unknown,
    Fortress,
    FootSoldier,
    Lancer,
    Priest,
    Archer,
    FireMage,
    IceMage
}
