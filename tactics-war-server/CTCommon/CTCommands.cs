using TacticsWarMud.TypeDefinitions;

namespace CTCommon
{
    public abstract class Command
    {
        public CommandType type;

        protected Command(CommandType type_)
        {
            type = type_;
        }
    };

    public class MoveCmd : Command
    {
        public CTCommon.Piece piece;
        public PositionData startPosition;
        public PositionData endPosition;

        [Obsolete("Maintained to be compatible with contract v1")]
        public List<PositionData>? path;

        [Obsolete("Maintained to be compatible with contract v1")]
        public MoveCmd(CTCommon.Piece piece_,
                List<PositionData>? path_) : base(CTCommon.CommandType.Move)
        {
            startPosition = new PositionData();
            endPosition = new PositionData();

            piece = piece_;
            path = path_;
        }

        public MoveCmd(CTCommon.Piece piece_,
                PositionData startPosition_,
                PositionData endPosition_) : base(CTCommon.CommandType.Move)
        {
            piece = piece_;
            startPosition = startPosition_;
            endPosition = endPosition_;
        }
    }

    public class AttackCmd : Command
    {
        public Piece attacker;
        public Piece target;

        public AttackCmd(Piece attacker_, Piece target_)
            : base(CTCommon.CommandType.Attack)
        {
            attacker = attacker_;
            target = target_;
        }
    }

    public class EndTurnCmd : Command
    {
        public int playerIndex;

        public EndTurnCmd(int playerIndex_)
            : base(CTCommon.CommandType.EndTurn)
        {
            playerIndex = playerIndex_;
        }
    };
}
