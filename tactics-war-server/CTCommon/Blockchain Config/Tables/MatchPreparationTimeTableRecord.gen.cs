using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchPreparationTimeTableService : TableService<MatchPreparationTimeTableRecord, MatchPreparationTimeTableRecord.MatchPreparationTimeKey, MatchPreparationTimeTableRecord.MatchPreparationTimeValue>
    { 
        public MatchPreparationTimeTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchPreparationTimeTableRecord : TableRecord<MatchPreparationTimeTableRecord.MatchPreparationTimeKey, MatchPreparationTimeTableRecord.MatchPreparationTimeValue> 
    {
        public MatchPreparationTimeTableRecord() : base("tacticsWar", "MatchPreparationTime")
        {
        
        }

        public partial class MatchPreparationTimeKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchPreparationTimeValue
        {
            [Parameter("uint256", "value", 1)]
            public virtual BigInteger Value { get; set; }          
        }
    }
}
