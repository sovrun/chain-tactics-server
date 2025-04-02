using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchPoolTableService : TableService<MatchPoolTableRecord, MatchPoolTableRecord.MatchPoolKey, MatchPoolTableRecord.MatchPoolValue>
    { 
        public MatchPoolTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchPoolTableRecord : TableRecord<MatchPoolTableRecord.MatchPoolKey, MatchPoolTableRecord.MatchPoolValue> 
    {
        public MatchPoolTableRecord() : base("tacticsWar", "MatchPool")
        {
        
        }

        public partial class MatchPoolKey
        {
            [Parameter("bytes32", "queueEntity", 1)]
            public virtual byte[] QueueEntity { get; set; }
        }

        public partial class MatchPoolValue
        {
            [Parameter("bytes32[]", "players", 1)]
            public virtual List<byte[]> Players { get; set; }          
        }
    }
}
