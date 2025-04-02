using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchWinnerTableService : TableService<MatchWinnerTableRecord, MatchWinnerTableRecord.MatchWinnerKey, MatchWinnerTableRecord.MatchWinnerValue>
    { 
        public MatchWinnerTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchWinnerTableRecord : TableRecord<MatchWinnerTableRecord.MatchWinnerKey, MatchWinnerTableRecord.MatchWinnerValue> 
    {
        public MatchWinnerTableRecord() : base("tacticsWar", "MatchWinner")
        {
        
        }

        public partial class MatchWinnerKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchWinnerValue
        {
            [Parameter("bytes32", "value", 1)]
            public virtual byte[] Value { get; set; }          
        }
    }
}
