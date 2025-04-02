using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class MatchConfigTableService : TableService<MatchConfigTableRecord, MatchConfigTableRecord.MatchConfigKey, MatchConfigTableRecord.MatchConfigValue>
    { 
        public MatchConfigTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class MatchConfigTableRecord : TableRecord<MatchConfigTableRecord.MatchConfigKey, MatchConfigTableRecord.MatchConfigValue> 
    {
        public MatchConfigTableRecord() : base("tacticsWar", "MatchConfig")
        {
        
        }

        public partial class MatchConfigKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class MatchConfigValue
        {
            [Parameter("bytes32", "boardEntity", 1)]
            public virtual byte[] BoardEntity { get; set; }
            [Parameter("bytes32", "gameModeEntity", 2)]
            public virtual byte[] GameModeEntity { get; set; }
            [Parameter("address", "createdBy", 3)]
            public virtual string CreatedBy { get; set; }
            [Parameter("uint256", "playerCount", 4)]
            public virtual BigInteger PlayerCount { get; set; }
            [Parameter("bool", "isPrivate", 5)]
            public virtual bool IsPrivate { get; set; }          
        }
    }
}
