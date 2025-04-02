using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class CommitTableService : TableService<CommitTableRecord, CommitTableRecord.CommitKey, CommitTableRecord.CommitValue>
    { 
        public CommitTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class CommitTableRecord : TableRecord<CommitTableRecord.CommitKey, CommitTableRecord.CommitValue> 
    {
        public CommitTableRecord() : base("tacticsWar", "Commit")
        {
        
        }

        public partial class CommitKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "playerEntity", 2)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class CommitValue
        {
            [Parameter("bytes32", "commitHashes", 1)]
            public virtual byte[] CommitHashes { get; set; }          
        }
    }
}
