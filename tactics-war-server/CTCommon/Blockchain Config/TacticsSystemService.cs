using System.Collections.Generic;
using Nethereum.Web3;
using Nethereum.Mud.Contracts.Core.Systems;
using TacticsWarMud.Systems.MatchSystem;
using TacticsWarMud.Systems.GameBoardSystem;
using TacticsWarMud.Systems.GameModeSystem;
using TacticsWarMud.Systems.BuySystem;
using TacticsWarMud.Systems.SpawnSystem;
using TacticsWarMud.Systems.MoveSystem;
using TacticsWarMud.Systems.CombatSystem;
using TacticsWarMud.Systems.TurnSystem;
using TacticsWarMud.Systems.ViewSystem;
using TacticsWarMud.Systems.PlayerSystem;

namespace TacticsWarMud
{
    public class TacticsSystemServices : SystemsServices
    {
        public MatchSystemService MatchSystemService { get; protected set; }
        public GameBoardSystemService GameBoardSystemService { get; protected set; }
        public GameModeSystemService GameModeSystemService { get; protected set; }
        public BuySystemService BuySystemService { get; protected set; }
        public SpawnSystemService SpawnSystemService { get; protected set; }
        public MoveSystemService MoveSystemService { get; protected set; }
        public CombatSystemService CombatSystemService { get; protected set; }
        public TurnSystemService TurnSystemService { get; protected set; }
        public ViewSystemService ViewSystemService { get; protected set; }
        public PlayerSystemService PlayerSystemService { get; protected set; }
        public TacticsSystemServices(IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
            MatchSystemService = new MatchSystemService(web3, contractAddress);
            GameBoardSystemService = new GameBoardSystemService(web3, contractAddress);
            GameModeSystemService = new GameModeSystemService(web3, contractAddress);
            BuySystemService = new BuySystemService(web3, contractAddress);
            SpawnSystemService = new SpawnSystemService(web3, contractAddress);
            MoveSystemService = new MoveSystemService(web3, contractAddress);
            CombatSystemService = new CombatSystemService(web3, contractAddress);
            TurnSystemService = new TurnSystemService(web3, contractAddress);
            ViewSystemService = new ViewSystemService(web3, contractAddress);
            PlayerSystemService = new PlayerSystemService(web3, contractAddress);
            SystemServices = new List<ISystemService>() { MatchSystemService, PlayerSystemService, BuySystemService, SpawnSystemService, MoveSystemService, CombatSystemService, TurnSystemService };
        }
    }
}
