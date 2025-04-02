using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class ActivePlayerTableService : TableService<ActivePlayerTableRecord, ActivePlayerTableRecord.ActivePlayerKey, ActivePlayerTableRecord.ActivePlayerValue>
    {
        public ActivePlayerTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) { }
    }

    public partial class ActivePlayerTableRecord : TableRecord<ActivePlayerTableRecord.ActivePlayerKey, ActivePlayerTableRecord.ActivePlayerValue>
    {
        public ActivePlayerTableRecord() : base("tacticsWar", "ActivePlayer")
        {

        }

        public partial class ActivePlayerKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class ActivePlayerValue
        {
            [Parameter("uint256", "playerIndex", 1)]
            public virtual BigInteger PlayerIndex { get; set; }
            [Parameter("uint256", "timestamp", 2)]
            public virtual BigInteger Timestamp { get; set; }
        }
    }
}
