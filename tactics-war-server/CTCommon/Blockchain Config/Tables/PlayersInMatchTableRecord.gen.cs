using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class PlayersInMatchTableService : TableService<PlayersInMatchTableRecord, PlayersInMatchTableRecord.PlayersInMatchKey, PlayersInMatchTableRecord.PlayersInMatchValue>
    { 
        public PlayersInMatchTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class PlayersInMatchTableRecord : TableRecord<PlayersInMatchTableRecord.PlayersInMatchKey, PlayersInMatchTableRecord.PlayersInMatchValue> 
    {
        public PlayersInMatchTableRecord() : base("tacticsWar", "PlayersInMatch")
        {
        
        }

        public partial class PlayersInMatchKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class PlayersInMatchValue
        {
            [Parameter("bytes32[]", "value", 1)]
            public virtual List<byte[]> Value { get; set; }          
        }
    }
}
