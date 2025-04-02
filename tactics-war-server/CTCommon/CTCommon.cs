using static CTCommon.ContractDefines;

namespace CTCommon
{
    public enum CommandType
    {
        Uknown,
        Move,
        Attack,
        EndTurn,
        Leave
    }

    public class Piece
    {
        public PieceType type { get; set; }
        public byte[] entity { get; set; }
        public int owner { get; set; }

        // Default constructor
        public Piece()
        {
            type = default(PieceType);
            entity = new byte[0];
            owner = 0;
        }

        // Parameterized constructor
        public Piece(ContractDefines.PieceType pieceType, byte[] pieceEntity, int pieceOwner)
        {
            type = pieceType;
            entity = pieceEntity;
            owner = pieceOwner;
        }
    }

    public class Cell
    {
        public CTCommon.Piece? piece;
    };
}
