using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class SpawnStatusTableService : TableService<SpawnStatusTableRecord, SpawnStatusTableRecord.SpawnStatusKey, SpawnStatusTableRecord.SpawnStatusValue>
    { 
        public SpawnStatusTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class SpawnStatusTableRecord : TableRecord<SpawnStatusTableRecord.SpawnStatusKey, SpawnStatusTableRecord.SpawnStatusValue> 
    {
        public SpawnStatusTableRecord() : base("tacticsWar", "SpawnStatus")
        {
        
        }

        public partial class SpawnStatusKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "playerEntity", 2)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class SpawnStatusValue
        {
            [Parameter("uint8", "value", 1)]
            public virtual byte Value { get; set; }          
        }
    }
}
