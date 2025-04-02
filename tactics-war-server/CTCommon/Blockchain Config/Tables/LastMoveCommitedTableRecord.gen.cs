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
    public partial class LastMoveCommitedTableService : TableService<LastMoveCommitedTableRecord, LastMoveCommitedTableRecord.LastMoveCommitedKey, LastMoveCommitedTableRecord.LastMoveCommitedValue>
    { 
        public LastMoveCommitedTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
        public virtual Task<LastMoveCommitedTableRecord> GetTableRecordAsync(byte[] matchEntity, BlockParameter blockParameter = null)
        {
            var _key = new LastMoveCommitedTableRecord.LastMoveCommitedKey();
            _key.MatchEntity = matchEntity;
            return GetTableRecordAsync(_key, blockParameter);
        }
        public virtual Task<string> SetRecordRequestAsync(byte[] matchEntity, byte[] pieceEntity, byte[] playerEntity, string playerAddress, uint x, uint y, BigInteger timestamp)
        {
            var _key = new LastMoveCommitedTableRecord.LastMoveCommitedKey();
            _key.MatchEntity = matchEntity;

            var _values = new LastMoveCommitedTableRecord.LastMoveCommitedValue();
            _values.PieceEntity = pieceEntity;
            _values.PlayerEntity = playerEntity;
            _values.PlayerAddress = playerAddress;
            _values.X = x;
            _values.Y = y;
            _values.Timestamp = timestamp;
            return SetRecordRequestAsync(_key, _values);
        }
        public virtual Task<TransactionReceipt> SetRecordRequestAndWaitForReceiptAsync(byte[] matchEntity, byte[] pieceEntity, byte[] playerEntity, string playerAddress, uint x, uint y, BigInteger timestamp)
        {
            var _key = new LastMoveCommitedTableRecord.LastMoveCommitedKey();
            _key.MatchEntity = matchEntity;

            var _values = new LastMoveCommitedTableRecord.LastMoveCommitedValue();
            _values.PieceEntity = pieceEntity;
            _values.PlayerEntity = playerEntity;
            _values.PlayerAddress = playerAddress;
            _values.X = x;
            _values.Y = y;
            _values.Timestamp = timestamp;
            return SetRecordRequestAndWaitForReceiptAsync(_key, _values);
        }
    }
    
    public partial class LastMoveCommitedTableRecord : TableRecord<LastMoveCommitedTableRecord.LastMoveCommitedKey, LastMoveCommitedTableRecord.LastMoveCommitedValue> 
    {
        public LastMoveCommitedTableRecord() : base("tacticsWar", "LastMoveCommited")
        {
        
        }
        /// <summary>
        /// Direct access to the key property 'MatchEntity'.
        /// </summary>
        public virtual byte[] MatchEntity => Keys.MatchEntity;
        /// <summary>
        /// Direct access to the value property 'PieceEntity'.
        /// </summary>
        public virtual byte[] PieceEntity => Values.PieceEntity;
        /// <summary>
        /// Direct access to the value property 'PlayerEntity'.
        /// </summary>
        public virtual byte[] PlayerEntity => Values.PlayerEntity;
        /// <summary>
        /// Direct access to the value property 'PlayerAddress'.
        /// </summary>
        public virtual string PlayerAddress => Values.PlayerAddress;
        /// <summary>
        /// Direct access to the value property 'X'.
        /// </summary>
        public virtual uint X => Values.X;
        /// <summary>
        /// Direct access to the value property 'Y'.
        /// </summary>
        public virtual uint Y => Values.Y;
        /// <summary>
        /// Direct access to the value property 'Timestamp'.
        /// </summary>
        public virtual BigInteger Timestamp => Values.Timestamp;

        public partial class LastMoveCommitedKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class LastMoveCommitedValue
        {
            [Parameter("bytes32", "pieceEntity", 1)]
            public virtual byte[] PieceEntity { get; set; }
            [Parameter("bytes32", "playerEntity", 2)]
            public virtual byte[] PlayerEntity { get; set; }
            [Parameter("address", "playerAddress", 3)]
            public virtual string PlayerAddress { get; set; }
            [Parameter("uint32", "x", 4)]
            public virtual uint X { get; set; }
            [Parameter("uint32", "y", 5)]
            public virtual uint Y { get; set; }
            [Parameter("uint256", "timestamp", 6)]
            public virtual BigInteger Timestamp { get; set; }          
        }
    }
}
