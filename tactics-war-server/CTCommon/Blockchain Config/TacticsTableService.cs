using Nethereum.Web3;
using Nethereum.Mud.Contracts.Core.Tables;
using TacticsWarMud.Tables;

namespace TacticsWarMud
{
    public class TacticsTableServices : TablesServices
    {
        public BoardConfigTableService BoardConfigTableService { get; protected set; }
        public GameModeTableService GameModeTableService { get; protected set; }
        public MatchEntityCounterTableService MatchEntityCounterTableService { get; protected set; }
        public MatchConfigTableService MatchConfigTableService { get; protected set; }
        public MatchStatusTableService MatchStatusTableService { get; protected set; }
        public MatchPreparationTimeTableService MatchPreparationTimeTableService { get; protected set; }
        public MatchPoolTableService MatchPoolTableService { get; protected set; }
        public MatchPlayersTableService MatchPlayersTableService { get; protected set; }
        public MatchPlayerTableService MatchPlayerTableService { get; protected set; }
        public MatchPlayerStatusTableService MatchPlayerStatusTableService { get; protected set; }
        public MatchPlayerSurrendersTableService MatchPlayerSurrendersTableService { get; protected set; }
        public MatchSurrenderCountTableService MatchSurrenderCountTableService { get; protected set; }
        public MatchWinnerTableService MatchWinnerTableService { get; protected set; }
        public MatchDefaultWinnerTableService MatchDefaultWinnerTableService { get; protected set; }
        public PlayerStatusTableService PlayerStatusTableService { get; protected set; }
        public PlayerInGameNameTableService PlayerInGameNameTableService { get; protected set; }
        public PlayersInMatchTableService PlayersInMatchTableService { get; protected set; }
        public SpawnStatusTableService SpawnStatusTableService { get; protected set; }
        public CommitTableService CommitTableService { get; protected set; }
        public InventoryTableService InventoryTableService { get; protected set; }
        public PrimaryPieceTableService PrimaryPieceTableService { get; protected set; }
        public PieceTableService PieceTableService { get; protected set; }
        public BattleTableService BattleTableService { get; protected set; }
        public MovementTableService MovementTableService { get; protected set; }
        public OwnedByTableService OwnedByTableService { get; protected set; }
        public PositionTableService PositionTableService { get; protected set; }
        public EntityAtPositionTableService EntityAtPositionTableService { get; protected set; }
        public ActivePlayerTableService ActivePlayerTableService { get; protected set; }
        public ActionStatusTableService ActionStatusTableService { get; protected set; }
        public LastAttackCommitedTableService LastAttackCommitedTableService { get; protected set; }
        public LastMoveCommitedTableService LastMoveCommitedTableService { get; protected set; }
        public PlayerTableService PlayerTableService { get; protected set; }
        public TacticsTableServices(IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
            PlayerTableService = new PlayerTableService(web3, contractAddress);

            BoardConfigTableService = new BoardConfigTableService(web3, contractAddress);
            GameModeTableService = new GameModeTableService(web3, contractAddress);
            MatchEntityCounterTableService = new MatchEntityCounterTableService(web3, contractAddress);
            MatchConfigTableService = new MatchConfigTableService(web3, contractAddress);
            MatchStatusTableService = new MatchStatusTableService(web3, contractAddress);
            MatchPreparationTimeTableService = new MatchPreparationTimeTableService(web3, contractAddress);
            MatchPoolTableService = new MatchPoolTableService(web3, contractAddress);
            MatchPlayersTableService = new MatchPlayersTableService(web3, contractAddress);
            MatchPlayerTableService = new MatchPlayerTableService(web3, contractAddress);
            MatchPlayerStatusTableService = new MatchPlayerStatusTableService(web3, contractAddress);
            MatchPlayerSurrendersTableService = new MatchPlayerSurrendersTableService(web3, contractAddress);
            MatchSurrenderCountTableService = new MatchSurrenderCountTableService(web3, contractAddress);
            MatchWinnerTableService = new MatchWinnerTableService(web3, contractAddress);
            MatchDefaultWinnerTableService = new MatchDefaultWinnerTableService(web3, contractAddress);
            PlayerStatusTableService = new PlayerStatusTableService(web3, contractAddress);
            PlayerInGameNameTableService = new PlayerInGameNameTableService(web3, contractAddress);
            PlayersInMatchTableService = new PlayersInMatchTableService(web3, contractAddress);
            SpawnStatusTableService = new SpawnStatusTableService(web3, contractAddress);
            CommitTableService = new CommitTableService(web3, contractAddress);
            InventoryTableService = new InventoryTableService(web3, contractAddress);
            PrimaryPieceTableService = new PrimaryPieceTableService(web3, contractAddress);
            PieceTableService = new PieceTableService(web3, contractAddress);
            BattleTableService = new BattleTableService(web3, contractAddress);
            MovementTableService = new MovementTableService(web3, contractAddress);
            OwnedByTableService = new OwnedByTableService(web3, contractAddress);
            PositionTableService = new PositionTableService(web3, contractAddress);
            EntityAtPositionTableService = new EntityAtPositionTableService(web3, contractAddress);
            ActivePlayerTableService = new ActivePlayerTableService(web3, contractAddress);
            ActionStatusTableService = new ActionStatusTableService(web3, contractAddress);
            LastAttackCommitedTableService = new LastAttackCommitedTableService(web3, contractAddress);
            LastMoveCommitedTableService = new LastMoveCommitedTableService(web3, contractAddress);
            TableServices = new List<ITableServiceBase> { MatchPlayerTableService, BoardConfigTableService, MatchEntityCounterTableService, MatchConfigTableService, MatchStatusTableService, MatchPreparationTimeTableService, MatchPoolTableService, MatchPlayersTableService, MatchPlayerTableService, MatchPlayerStatusTableService, MatchPlayerSurrendersTableService, MatchSurrenderCountTableService, MatchWinnerTableService, MatchDefaultWinnerTableService, PlayerTableService, PlayerInGameNameTableService, PlayersInMatchTableService, SpawnStatusTableService, CommitTableService, InventoryTableService, PrimaryPieceTableService, PieceTableService, BattleTableService, MovementTableService, OwnedByTableService, PositionTableService, EntityAtPositionTableService, ActivePlayerTableService, ActionStatusTableService, LastAttackCommitedTableService, LastMoveCommitedTableService };
        }
    }
}
