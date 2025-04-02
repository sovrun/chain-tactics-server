namespace CTCommon
{
    public class ContractDefines
    {
        public enum MatchStatusTypes : byte
        {
            None,
            Pending,
            Preparing,
            Active,
            Finished,
            Cancelled
        }

        public enum MatchPlayerStatusTypes : byte
        {
            None,
            Waiting,
            Matched,
            Ready
        }

        public enum SpawnStatusTypes : byte
        {
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

        public enum PlayerStatusTypes : byte
        {
            None, // Player has no status
            Queueing, // Player is in the matchmaking queue
            Playing // Player is currently in a match
        }

        public enum PieceType : byte
        {
            Unknown,
            Fortress,
            FootSoldier,
            Lancer,
            Priest,
            Archer,
            FireMage,
            IceMage
        }
    };
}
