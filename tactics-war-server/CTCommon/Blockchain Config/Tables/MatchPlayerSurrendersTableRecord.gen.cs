using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchPlayerSurrendersTableService : TableService<MatchPlayerSurrendersTableRecord, MatchPlayerSurrendersTableRecord.MatchPlayerSurrendersKey, MatchPlayerSurrendersTableRecord.MatchPlayerSurrendersValue>
    { 
        public MatchPlayerSurrendersTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchPlayerSurrendersTableRecord : TableRecord<MatchPlayerSurrendersTableRecord.MatchPlayerSurrendersKey, MatchPlayerSurrendersTableRecord.MatchPlayerSurrendersValue> 
    {
        public MatchPlayerSurrendersTableRecord() : base("tacticsWar", "MatchPlayerSurrenders")
        {
        
        }

        public partial class MatchPlayerSurrendersKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "playerEntity", 2)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class MatchPlayerSurrendersValue
        {
            [Parameter("bool", "value", 1)]
            public virtual bool Value { get; set; }          
        }
    }
}
