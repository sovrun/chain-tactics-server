using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class PlayerQueueTableService : TableService<PlayerQueueTableRecord, PlayerQueueTableRecord.PlayerQueueKey, PlayerQueueTableRecord.PlayerQueueValue>
    { 
        public PlayerQueueTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class PlayerQueueTableRecord : TableRecord<PlayerQueueTableRecord.PlayerQueueKey, PlayerQueueTableRecord.PlayerQueueValue> 
    {
        public PlayerQueueTableRecord() : base("tacticsWar", "PlayerQueue")
        {
        
        }

        public partial class PlayerQueueKey
        {
            [Parameter("bytes32", "playerEntity", 1)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class PlayerQueueValue
        {
            [Parameter("bytes32", "value", 1)]
            public virtual byte[] Value { get; set; }          
        }
    }
}
