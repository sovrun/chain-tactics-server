using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class OwnedByTableService : TableService<OwnedByTableRecord, OwnedByTableRecord.OwnedByKey, OwnedByTableRecord.OwnedByValue>
    { 
        public OwnedByTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class OwnedByTableRecord : TableRecord<OwnedByTableRecord.OwnedByKey, OwnedByTableRecord.OwnedByValue> 
    {
        public OwnedByTableRecord() : base("tacticsWar", "OwnedBy")
        {
        
        }

        public partial class OwnedByKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class OwnedByValue
        {
            [Parameter("bytes32", "value", 1)]
            public virtual byte[] Value { get; set; }          
        }
    }
}
