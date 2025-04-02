using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class PlayerTableService : TableService<PlayerTableRecord, PlayerTableRecord.PlayerKey, PlayerTableRecord.PlayerValue>
    { 
        public PlayerTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class PlayerTableRecord : TableRecord<PlayerTableRecord.PlayerKey, PlayerTableRecord.PlayerValue> 
    {
        public PlayerTableRecord() : base("tacticsWar", "Player")
        {
        
        }

        public partial class PlayerKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class PlayerValue
        {
            [Parameter("bool", "value", 1)]
            public virtual bool Value { get; set; }          
        }
    }
}
