using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;

namespace TacticsWarMud.Tables
{
    public partial class InventoryTableService : TableService<InventoryTableRecord, InventoryTableRecord.InventoryKey, InventoryTableRecord.InventoryValue>
    { 
        public InventoryTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
    }
    
    public partial class InventoryTableRecord : TableRecord<InventoryTableRecord.InventoryKey, InventoryTableRecord.InventoryValue> 
    {
        public InventoryTableRecord() : base("tacticsWar", "Inventory")
        {
        
        }

        public partial class InventoryKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
            [Parameter("bytes32", "playerEntity", 2)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class InventoryValue
        {
            [Parameter("uint256", "balance", 1)]
            public virtual BigInteger Balance { get; set; }
            [Parameter("bytes32[]", "pieces", 2)]
            public virtual List<byte[]> Pieces { get; set; }          
        }
    }
}
