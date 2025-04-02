using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class PrimaryPieceTableService : TableService<PrimaryPieceTableRecord, PrimaryPieceTableRecord.PrimaryPieceKey, PrimaryPieceTableRecord.PrimaryPieceValue>
    { 
        public PrimaryPieceTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class PrimaryPieceTableRecord : TableRecord<PrimaryPieceTableRecord.PrimaryPieceKey, PrimaryPieceTableRecord.PrimaryPieceValue> 
    {
        public PrimaryPieceTableRecord() : base("tacticsWar", "PrimaryPiece")
        {
        
        }

        public partial class PrimaryPieceKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class PrimaryPieceValue
        {
            [Parameter("bool", "value", 1)]
            public virtual bool Value { get; set; }          
        }
    }
}
