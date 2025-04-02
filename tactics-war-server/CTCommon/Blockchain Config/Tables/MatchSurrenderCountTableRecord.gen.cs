using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchSurrenderCountTableService : TableService<MatchSurrenderCountTableRecord, MatchSurrenderCountTableRecord.MatchSurrenderCountKey, MatchSurrenderCountTableRecord.MatchSurrenderCountValue>
    { 
        public MatchSurrenderCountTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchSurrenderCountTableRecord : TableRecord<MatchSurrenderCountTableRecord.MatchSurrenderCountKey, MatchSurrenderCountTableRecord.MatchSurrenderCountValue> 
    {
        public MatchSurrenderCountTableRecord() : base("tacticsWar", "MatchSurrenderCount")
        {
        
        }

        public partial class MatchSurrenderCountKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchSurrenderCountValue
        {
            [Parameter("uint256", "value", 1)]
            public virtual BigInteger Value { get; set; }          
        }
    }
}
