using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class EntityAtPositionTableService : TableService<EntityAtPositionTableRecord, EntityAtPositionTableRecord.EntityAtPositionKey, EntityAtPositionTableRecord.EntityAtPositionValue>
    { 
        public EntityAtPositionTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class EntityAtPositionTableRecord : TableRecord<EntityAtPositionTableRecord.EntityAtPositionKey, EntityAtPositionTableRecord.EntityAtPositionValue> 
    {
        public EntityAtPositionTableRecord() : base("tacticsWar", "EntityAtPosition")
        {
        
        }

        public partial class EntityAtPositionKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("uint32", "x", 2)]
            public virtual uint X { get; set; }
            [Parameter("uint32", "y", 3)]
            public virtual uint Y { get; set; }
        }

        public partial class EntityAtPositionValue
        {
            [Parameter("bytes32", "value", 1)]
            public virtual byte[] Value { get; set; }          
        }
    }
}
