using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class PieceTableService : TableService<PieceTableRecord, PieceTableRecord.PieceKey, PieceTableRecord.PieceValue>
    { 
        public PieceTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class PieceTableRecord : TableRecord<PieceTableRecord.PieceKey, PieceTableRecord.PieceValue> 
    {
        public PieceTableRecord() : base("tacticsWar", "Piece")
        {
        
        }

        public partial class PieceKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class PieceValue
        {
            [Parameter("uint256", "value", 1)]
            public virtual BigInteger Value { get; set; }          
        }
    }
}
