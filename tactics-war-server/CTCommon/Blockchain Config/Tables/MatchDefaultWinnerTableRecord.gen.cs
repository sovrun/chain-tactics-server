using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchDefaultWinnerTableService : TableService<MatchDefaultWinnerTableRecord, MatchDefaultWinnerTableRecord.MatchDefaultWinnerKey, MatchDefaultWinnerTableRecord.MatchDefaultWinnerValue>
    { 
        public MatchDefaultWinnerTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchDefaultWinnerTableRecord : TableRecord<MatchDefaultWinnerTableRecord.MatchDefaultWinnerKey, MatchDefaultWinnerTableRecord.MatchDefaultWinnerValue> 
    {
        public MatchDefaultWinnerTableRecord() : base("tacticsWar", "MatchDefaultWinner")
        {
        
        }

        public partial class MatchDefaultWinnerKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchDefaultWinnerValue
        {
            [Parameter("bytes32", "value", 1)]
            public virtual byte[] Value { get; set; }          
        }
    }
}
