using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MovementTableService : TableService<MovementTableRecord, MovementTableRecord.MovementKey, MovementTableRecord.MovementValue>
    { 
        public MovementTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MovementTableRecord : TableRecord<MovementTableRecord.MovementKey, MovementTableRecord.MovementValue> 
    {
        public MovementTableRecord() : base("tacticsWar", "Movement")
        {
        
        }

        public partial class MovementKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class MovementValue
        {
            [Parameter("uint256", "value", 1)]
            public virtual BigInteger Value { get; set; }          
        }
    }
}
