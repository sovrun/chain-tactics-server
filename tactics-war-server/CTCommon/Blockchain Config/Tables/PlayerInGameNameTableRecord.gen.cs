using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Mud;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Mud.Contracts.Core.Tables;
using Nethereum.Web3;
using System.Collections.Generic;
using System.Numerics;
using System.Threading.Tasks;

namespace TacticsWarMud.Tables
{
    public partial class PlayerInGameNameTableService : TableService<PlayerInGameNameTableRecord, PlayerInGameNameTableRecord.PlayerInGameNameKey, PlayerInGameNameTableRecord.PlayerInGameNameValue>
    { 
        public PlayerInGameNameTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
        public virtual Task<PlayerInGameNameTableRecord> GetTableRecordAsync(byte[] playerEntity, BlockParameter blockParameter = null)
        {
            var _key = new PlayerInGameNameTableRecord.PlayerInGameNameKey();
            _key.PlayerEntity = playerEntity;
            return GetTableRecordAsync(_key, blockParameter);
        }
        public virtual Task<string> SetRecordRequestAsync(byte[] playerEntity, string value)
        {
            var _key = new PlayerInGameNameTableRecord.PlayerInGameNameKey();
            _key.PlayerEntity = playerEntity;

            var _values = new PlayerInGameNameTableRecord.PlayerInGameNameValue();
            _values.Value = value;
            return SetRecordRequestAsync(_key, _values);
        }
        public virtual Task<TransactionReceipt> SetRecordRequestAndWaitForReceiptAsync(byte[] playerEntity, string value)
        {
            var _key = new PlayerInGameNameTableRecord.PlayerInGameNameKey();
            _key.PlayerEntity = playerEntity;

            var _values = new PlayerInGameNameTableRecord.PlayerInGameNameValue();
            _values.Value = value;
            return SetRecordRequestAndWaitForReceiptAsync(_key, _values);
        }
    }
    
    public partial class PlayerInGameNameTableRecord : TableRecord<PlayerInGameNameTableRecord.PlayerInGameNameKey, PlayerInGameNameTableRecord.PlayerInGameNameValue> 
    {
        public PlayerInGameNameTableRecord() : base("tacticsWar", "PlayerInGameName")
        {
        
        }
        /// <summary>
        /// Direct access to the key property 'PlayerEntity'.
        /// </summary>
        public virtual byte[] PlayerEntity => Keys.PlayerEntity;
        /// <summary>
        /// Direct access to the value property 'Value'.
        /// </summary>
        public virtual string Value => Values.Value;

        public partial class PlayerInGameNameKey
        {
            [Parameter("bytes32", "playerEntity", 1)]
            public virtual byte[] PlayerEntity { get; set; }
        }

        public partial class PlayerInGameNameValue
        {
            [Parameter("string", "value", 1)]
            public virtual string Value { get; set; }          
        }
    }
}
