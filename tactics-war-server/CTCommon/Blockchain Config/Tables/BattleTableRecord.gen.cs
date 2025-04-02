using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class BattleTableService : TableService<BattleTableRecord, BattleTableRecord.BattleKey, BattleTableRecord.BattleValue>
    { 
        public BattleTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class BattleTableRecord : TableRecord<BattleTableRecord.BattleKey, BattleTableRecord.BattleValue> 
    {
        public BattleTableRecord() : base("tacticsWar", "Battle")
        {
        
        }

        public partial class BattleKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "entity", 2)]
            public virtual byte[] Entity { get; set; }
        }

        public partial class BattleValue
        {
            [Parameter("uint256", "health", 1)]
            public virtual BigInteger Health { get; set; }
            [Parameter("uint256", "damage", 2)]
            public virtual BigInteger Damage { get; set; }
            [Parameter("uint256", "attackType", 3)]
            public virtual BigInteger AttackType { get; set; }
            [Parameter("uint256", "range", 4)]
            public virtual BigInteger Range { get; set; }
            [Parameter("uint256", "blindspot", 5)]
            public virtual BigInteger Blindspot { get; set; }          
        }
    }
}
