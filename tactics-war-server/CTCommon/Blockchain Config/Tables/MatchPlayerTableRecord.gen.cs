using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchPlayerTableService : TableService<MatchPlayerTableRecord, MatchPlayerTableRecord.MatchPlayerKey, MatchPlayerTableRecord.MatchPlayerValue>
    { 
        public MatchPlayerTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchPlayerTableRecord : TableRecord<MatchPlayerTableRecord.MatchPlayerKey, MatchPlayerTableRecord.MatchPlayerValue> 
    {
        public MatchPlayerTableRecord() : base("tacticsWar", "MatchPlayer")
        {
        
        }

        public partial class MatchPlayerKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("address", "player", 2)]
            public virtual string Player { get; set; }
        }

        public partial class MatchPlayerValue
        {
            [Parameter("bytes32", "value", 1)]
            public virtual byte[] Value { get; set; }          
        }
    }
}
