using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class PlayerStatusTableService : TableService<PlayerStatusTableRecord, PlayerStatusTableRecord.PlayerStatusKey, PlayerStatusTableRecord.PlayerStatusValue>
    {
        public PlayerStatusTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) { }
    }

    public partial class PlayerStatusTableRecord : TableRecord<PlayerStatusTableRecord.PlayerStatusKey, PlayerStatusTableRecord.PlayerStatusValue>
    {
        public PlayerStatusTableRecord() : base("tacticsWar", "PlayerStatus")
        {

        }

        public partial class PlayerStatusKey
        {
            [Parameter("bytes32", "playerEntity", 1)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class PlayerStatusValue
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "matchPlayerEntity", 2)]
            public virtual byte[] MatchPlayerEntity { get; set; }
            [Parameter("uint8", "status", 3)]
            public virtual byte Status { get; set; }
        }
    }
}
