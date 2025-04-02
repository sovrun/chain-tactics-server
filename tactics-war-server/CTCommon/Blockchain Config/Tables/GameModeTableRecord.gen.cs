using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class GameModeTableService : TableService<GameModeTableRecord, GameModeTableRecord.GameModeKey, GameModeTableRecord.GameModeValue>
    { 
        public GameModeTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class GameModeTableRecord : TableRecord<GameModeTableRecord.GameModeKey, GameModeTableRecord.GameModeValue> 
    {
        public GameModeTableRecord() : base("tacticsWar", "GameMode")
        {
        
        }

        public partial class GameModeKey
        {
            [Parameter("bytes32", "gameModeEntity", 1)]
            public virtual byte[] GameModeEntity { get; set; }
        }

        public partial class GameModeValue
        {
            [Parameter("uint256", "totalTurn", 1)]
            public virtual BigInteger TotalTurn { get; set; }
            [Parameter("uint256", "playerTimeDuration", 2)]
            public virtual BigInteger PlayerTimeDuration { get; set; }
            [Parameter("uint256", "turnTimeIncrement", 3)]
            public virtual BigInteger TurnTimeIncrement { get; set; }
            [Parameter("uint256", "prepTime", 4)]
            public virtual BigInteger PrepTime { get; set; }          
        }
    }
}
