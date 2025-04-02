using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchStatusTableService : TableService<MatchStatusTableRecord, MatchStatusTableRecord.MatchStatusKey, MatchStatusTableRecord.MatchStatusValue>
    { 
        public MatchStatusTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchStatusTableRecord : TableRecord<MatchStatusTableRecord.MatchStatusKey, MatchStatusTableRecord.MatchStatusValue> 
    {
        public MatchStatusTableRecord() : base("tacticsWar", "MatchStatus")
        {
        
        }

        public partial class MatchStatusKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchStatusValue
        {
            [Parameter("uint8", "value", 1)]
            public virtual byte Value { get; set; }          
        }
    }
}
