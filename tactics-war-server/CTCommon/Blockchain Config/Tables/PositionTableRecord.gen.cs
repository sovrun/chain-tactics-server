using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class PositionTableService : TableService<PositionTableRecord, PositionTableRecord.PositionKey, PositionTableRecord.PositionValue>
    { 
        public PositionTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class PositionTableRecord : TableRecord<PositionTableRecord.PositionKey, PositionTableRecord.PositionValue> 
    {
        public PositionTableRecord() : base("tacticsWar", "Position")
        {
        
        }

        public partial class PositionKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class PositionValue
        {
            [Parameter("uint32", "x", 1)]
            public virtual uint X { get; set; }
            [Parameter("uint32", "y", 2)]
            public virtual uint Y { get; set; }          
        }
    }
}
