using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchEntityCounterTableService : TableService<MatchEntityCounterTableRecord, MatchEntityCounterTableRecord.MatchEntityCounterKey, MatchEntityCounterTableRecord.MatchEntityCounterValue>
    { 
        public MatchEntityCounterTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchEntityCounterTableRecord : TableRecord<MatchEntityCounterTableRecord.MatchEntityCounterKey, MatchEntityCounterTableRecord.MatchEntityCounterValue> 
    {
        public MatchEntityCounterTableRecord() : base("tacticsWar", "MatchEntityCounter")
        {
        
        }

        public partial class MatchEntityCounterKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchEntityCounterValue
        {
            [Parameter("uint256", "entityCounter", 1)]
            public virtual BigInteger EntityCounter { get; set; }          
        }
    }
}
