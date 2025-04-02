using Nethereum.ABI.FunctionEncoding.Attributes;

namespace TacticsWarMud.SystemDefinition
{
    public partial class NotPlayerTurnError : NotPlayerTurnErrorBase { }

    [Error("NotPlayerTurn")]
    public class NotPlayerTurnErrorBase : IErrorDTO
    {
        [Parameter("address", "player", 1)]
        public virtual string Player { get; set; }
    }

    public partial class MatchNotActiveError : MatchNotActiveErrorBase { }
    [Error("MatchNotActive")]
    public class MatchNotActiveErrorBase : IErrorDTO
    {
    }

    public partial class MatchNotPreparingError : MatchNotPreparingErrorBase { }
    [Error("MatchNotPreparing")]
    public class MatchNotPreparingErrorBase : IErrorDTO
    {
    }

    public partial class NotInQueueOrMatchError : NotInQueueOrMatchErrorBase { }
    [Error("NotInQueueOrMatch")]
    public class NotInQueueOrMatchErrorBase : IErrorDTO
    {
    }

    public partial class PlayerAlreadyInQueueError : PlayerAlreadyInQueueErrorBase { }
    [Error("PlayerAlreadyInQueue")]
    public class PlayerAlreadyInQueueErrorBase : IErrorDTO
    {
    }

    public partial class PlayerAlreadyReadyError : PlayerAlreadyReadyErrorBase { }
    [Error("PlayerAlreadyReady")]
    public class PlayerAlreadyReadyErrorBase : IErrorDTO
    {
    }

    public partial class PlayerHasOngoingMatchError : PlayerHasOngoingMatchErrorBase { }
    [Error("PlayerHasOngoingMatch")]
    public class PlayerHasOngoingMatchErrorBase : IErrorDTO
    {
    }

    public partial class PlayerNotInMatchError : PlayerNotInMatchErrorBase { }
    [Error("PlayerNotInMatch")]
    public class PlayerNotInMatchErrorBase : IErrorDTO
    {
    }

    public partial class PreparationTimeOverError : PreparationTimeOverErrorBase { }
    [Error("PreparationTimeOver")]
    public class PreparationTimeOverErrorBase : IErrorDTO
    {
    }

    public partial class IncorrectCommitStatusError : IncorrectCommitStatusErrorBase { }
    [Error("IncorrectCommitStatus")]
    public class IncorrectCommitStatusErrorBase : IErrorDTO
    {
    }

    public partial class IncorrectRevealStatusError : IncorrectRevealStatusErrorBase { }
    [Error("IncorrectRevealStatus")]
    public class IncorrectRevealStatusErrorBase : IErrorDTO
    {
    }

    public partial class InvalidRevealError : InvalidRevealErrorBase { }
    [Error("InvalidReveal")]
    public class InvalidRevealErrorBase : IErrorDTO
    {
    }

    public partial class NoCommitHashError : NoCommitHashErrorBase { }
    [Error("NoCommitHash")]
    public class NoCommitHashErrorBase : IErrorDTO
    {
    }

    public partial class NotEnoughGoldError : NotEnoughGoldErrorBase { }
    [Error("NotEnoughGold")]
    public class NotEnoughGoldErrorBase : IErrorDTO
    {
    }

    public partial class PieceNotAllowedToBuyError : PieceNotAllowedToBuyErrorBase { }
    [Error("PieceNotAllowedToBuy")]
    public class PieceNotAllowedToBuyErrorBase : IErrorDTO
    {
    }

    public partial class CoordinateNotAllowedError : CoordinateNotAllowedErrorBase { }
    [Error("CoordinateNotAllowed")]
    public class CoordinateNotAllowedErrorBase : IErrorDTO
    {
    }

    public partial class NotInSpawnAreaError : NotInSpawnAreaErrorBase { }
    [Error("NotInSpawnArea")]
    public class NotInSpawnAreaErrorBase : IErrorDTO
    {
    }

    public partial class PositionOccupiedError : PositionOccupiedErrorBase { }
    [Error("PositionOccupied")]
    public class PositionOccupiedErrorBase : IErrorDTO
    {
    }

    public partial class ExceededMovesAllowedError : ExceededMovesAllowedErrorBase { }
    [Error("ExceededMovesAllowed")]
    public class ExceededMovesAllowedErrorBase : IErrorDTO
    {
    }

    public partial class InvalidMoveError : InvalidMoveErrorBase { }
    [Error("InvalidMove")]
    public class InvalidMoveErrorBase : IErrorDTO
    {
    }

    public partial class InvalidPathError : InvalidPathErrorBase { }
    [Error("InvalidPath")]
    public class InvalidPathErrorBase : IErrorDTO
    {
    }

    public partial class NotSelectedPieceError : NotSelectedPieceErrorBase { }
    [Error("NotSelectedPiece")]
    public class NotSelectedPieceErrorBase : IErrorDTO
    {
    }

    public partial class PieceNotExistsError : PieceNotExistsErrorBase { }
    [Error("PieceNotExists")]
    public class PieceNotExistsErrorBase : IErrorDTO
    {
    }

    public partial class PieceNotOwnedError : PieceNotOwnedErrorBase { }
    [Error("PieceNotOwned")]
    public class PieceNotOwnedErrorBase : IErrorDTO
    {
    }

    public partial class InvalidActionError : InvalidActionErrorBase { }
    [Error("InvalidAction")]
    public class InvalidActionErrorBase : IErrorDTO
    {
    }

    public partial class InvalidAttackError : InvalidAttackErrorBase { }
    [Error("InvalidAttack")]
    public class InvalidAttackErrorBase : IErrorDTO
    {
    }

    public partial class EmptyPlayerNameError : EmptyPlayerNameErrorBase { }
    [Error("EmptyPlayerName")]
    public class EmptyPlayerNameErrorBase : IErrorDTO
    {
    }
}