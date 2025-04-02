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
    public partial class LastAttackCommitedTableService : TableService<LastAttackCommitedTableRecord, LastAttackCommitedTableRecord.LastAttackCommitedKey, LastAttackCommitedTableRecord.LastAttackCommitedValue>
    { 
        public LastAttackCommitedTableService(IWeb3 web3, string contractAddress) : base(web3, contractAddress) {}
        public virtual Task<LastAttackCommitedTableRecord> GetTableRecordAsync(byte[] matchEntity, BlockParameter blockParameter = null)
        {
            var _key = new LastAttackCommitedTableRecord.LastAttackCommitedKey();
            _key.MatchEntity = matchEntity;
            return GetTableRecordAsync(_key, blockParameter);
        }
        public virtual Task<string> SetRecordRequestAsync(byte[] matchEntity, byte[] targetPieceEntity, byte[] attackerPieceEntity, byte[] attackerPlayerEntity, string attackerPlayerAddress, BigInteger targetPieceCurrentHealth, BigInteger timestamp)
        {
            var _key = new LastAttackCommitedTableRecord.LastAttackCommitedKey();
            _key.MatchEntity = matchEntity;

            var _values = new LastAttackCommitedTableRecord.LastAttackCommitedValue();
            _values.TargetPieceEntity = targetPieceEntity;
            _values.AttackerPieceEntity = attackerPieceEntity;
            _values.AttackerPlayerEntity = attackerPlayerEntity;
            _values.AttackerPlayerAddress = attackerPlayerAddress;
            _values.TargetPieceCurrentHealth = targetPieceCurrentHealth;
            _values.Timestamp = timestamp;
            return SetRecordRequestAsync(_key, _values);
        }
        public virtual Task<TransactionReceipt> SetRecordRequestAndWaitForReceiptAsync(byte[] matchEntity, byte[] targetPieceEntity, byte[] attackerPieceEntity, byte[] attackerPlayerEntity, string attackerPlayerAddress, BigInteger targetPieceCurrentHealth, BigInteger timestamp)
        {
            var _key = new LastAttackCommitedTableRecord.LastAttackCommitedKey();
            _key.MatchEntity = matchEntity;

            var _values = new LastAttackCommitedTableRecord.LastAttackCommitedValue();
            _values.TargetPieceEntity = targetPieceEntity;
            _values.AttackerPieceEntity = attackerPieceEntity;
            _values.AttackerPlayerEntity = attackerPlayerEntity;
            _values.AttackerPlayerAddress = attackerPlayerAddress;
            _values.TargetPieceCurrentHealth = targetPieceCurrentHealth;
            _values.Timestamp = timestamp;
            return SetRecordRequestAndWaitForReceiptAsync(_key, _values);
        }
    }
    
    public partial class LastAttackCommitedTableRecord : TableRecord<LastAttackCommitedTableRecord.LastAttackCommitedKey, LastAttackCommitedTableRecord.LastAttackCommitedValue> 
    {
        public LastAttackCommitedTableRecord() : base("tacticsWar", "LastAttackCommited")
        {
        
        }
        /// <summary>
        /// Direct access to the key property 'MatchEntity'.
        /// </summary>
        public virtual byte[] MatchEntity => Keys.MatchEntity;
        /// <summary>
        /// Direct access to the value property 'TargetPieceEntity'.
        /// </summary>
        public virtual byte[] TargetPieceEntity => Values.TargetPieceEntity;
        /// <summary>
        /// Direct access to the value property 'AttackerPieceEntity'.
        /// </summary>
        public virtual byte[] AttackerPieceEntity => Values.AttackerPieceEntity;
        /// <summary>
        /// Direct access to the value property 'AttackerPlayerEntity'.
        /// </summary>
        public virtual byte[] AttackerPlayerEntity => Values.AttackerPlayerEntity;
        /// <summary>
        /// Direct access to the value property 'AttackerPlayerAddress'.
        /// </summary>
        public virtual string AttackerPlayerAddress => Values.AttackerPlayerAddress;
        /// <summary>
        /// Direct access to the value property 'TargetPieceCurrentHealth'.
        /// </summary>
        public virtual BigInteger TargetPieceCurrentHealth => Values.TargetPieceCurrentHealth;
        /// <summary>
        /// Direct access to the value property 'Timestamp'.
        /// </summary>
        public virtual BigInteger Timestamp => Values.Timestamp;

        public partial class LastAttackCommitedKey
        {
            [Parameter("bytes32", "matchEntity", 1)]
            public virtual byte[] MatchEntity { get; set; }
        }

        public partial class LastAttackCommitedValue
        {
            [Parameter("bytes32", "targetPieceEntity", 1)]
            public virtual byte[] TargetPieceEntity { get; set; }
            [Parameter("bytes32", "attackerPieceEntity", 2)]
            public virtual byte[] AttackerPieceEntity { get; set; }
            [Parameter("bytes32", "attackerPlayerEntity", 3)]
            public virtual byte[] AttackerPlayerEntity { get; set; }
            [Parameter("address", "attackerPlayerAddress", 4)]
            public virtual string AttackerPlayerAddress { get; set; }
            [Parameter("uint256", "targetPieceCurrentHealth", 5)]
            public virtual BigInteger TargetPieceCurrentHealth { get; set; }
            [Parameter("uint256", "timestamp", 6)]
            public virtual BigInteger Timestamp { get; set; }          
        }
    }
}
