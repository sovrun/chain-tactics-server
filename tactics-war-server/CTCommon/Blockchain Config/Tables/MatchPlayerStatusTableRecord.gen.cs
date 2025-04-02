using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchPlayerStatusTableService : TableService<MatchPlayerStatusTableRecord, MatchPlayerStatusTableRecord.MatchPlayerStatusKey, MatchPlayerStatusTableRecord.MatchPlayerStatusValue>
    { 
        public MatchPlayerStatusTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchPlayerStatusTableRecord : TableRecord<MatchPlayerStatusTableRecord.MatchPlayerStatusKey, MatchPlayerStatusTableRecord.MatchPlayerStatusValue> 
    {
        public MatchPlayerStatusTableRecord() : base("tacticsWar", "MatchPlayerStatus")
        {
        
        }

        public partial class MatchPlayerStatusKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class MatchPlayerStatusValue
        {
            [Parameter("uint8", "value", 1)]
            public virtual byte Value { get; set; }          
        }
    }
}
