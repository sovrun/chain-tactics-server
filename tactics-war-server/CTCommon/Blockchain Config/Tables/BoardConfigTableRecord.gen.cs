using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class BoardConfigTableService : TableService<BoardConfigTableRecord, BoardConfigTableRecord.BoardConfigKey, BoardConfigTableRecord.BoardConfigValue>
    { 
        public BoardConfigTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class BoardConfigTableRecord : TableRecord<BoardConfigTableRecord.BoardConfigKey, BoardConfigTableRecord.BoardConfigValue> 
    {
        public BoardConfigTableRecord() : base("tacticsWar", "BoardConfig")
        {
        
        }

        public partial class BoardConfigKey
        {
            [Parameter("bytes32", "boardEntity", 1)]
            public virtual byte[] BoardEntity { get; set; }
        }

        public partial class BoardConfigValue
        {
            [Parameter("uint256", "rows", 1)]
            public virtual BigInteger Rows { get; set; }
            [Parameter("uint256", "columns", 2)]
            public virtual BigInteger Columns { get; set; }          
        }
    }
}
