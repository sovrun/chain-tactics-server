using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class ActionStatusTableService : TableService<ActionStatusTableRecord, ActionStatusTableRecord.ActionStatusKey, ActionStatusTableRecord.ActionStatusValue>
    { 
        public ActionStatusTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class ActionStatusTableRecord : TableRecord<ActionStatusTableRecord.ActionStatusKey, ActionStatusTableRecord.ActionStatusValue> 
    {
        public ActionStatusTableRecord() : base("tacticsWar", "ActionStatus")
        {
        
        }

        public partial class ActionStatusKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "playerEntity", 2)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class ActionStatusValue
        {
            [Parameter("bytes32", "selectedPiece", 1)]
            public virtual byte[] SelectedPiece { get; set; }
            [Parameter("uint256", "movesExecuted", 2)]
            public virtual BigInteger MovesExecuted { get; set; }
            [Parameter("uint256", "battlesExecuted", 3)]
            public virtual BigInteger BattlesExecuted { get; set; }          
        }
    }
}
