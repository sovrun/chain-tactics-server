using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchPlayersTableService : TableService<MatchPlayersTableRecord, MatchPlayersTableRecord.MatchPlayersKey, MatchPlayersTableRecord.MatchPlayersValue>
    {
        public MatchPlayersTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) { }
    }

    public partial class MatchPlayersTableRecord : TableRecord<MatchPlayersTableRecord.MatchPlayersKey, MatchPlayersTableRecord.MatchPlayersValue>
    {
        public MatchPlayersTableRecord() : base("tacticsWar", "MatchPlayers")
        {

        }

        public partial class MatchPlayersKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchPlayersValue
        {
            [Parameter("bytes32[]", "value", 1)]
            public virtual List<byte[]> Value { get; set; }
        }
    }
}
