using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts.ContractHandlers;
using Nethereum.Contracts;
using System.Threading;
using TacticsWarMud.SystemDefinition;
using TacticsWarMud.TypeDefinitions;

namespace TacticsWarMud.Systems.CombatSystem
{
    public partial class CombatSystemService : ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, CombatSystemDeployment combatSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<CombatSystemDeployment>().SendRequestAndWaitForReceiptAsync(combatSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, CombatSystemDeployment combatSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<CombatSystemDeployment>().SendRequestAsync(combatSystemDeployment);
        }

        public static async Task<CombatSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, CombatSystemDeployment combatSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, combatSystemDeployment, cancellationTokenSource);
            return new CombatSystemService(web3, receipt.ContractAddress);
        }

        public CombatSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

        public Task<string> MsgSenderQueryAsync(MsgSenderFunction msgSenderFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgSenderFunction, string>(msgSenderFunction, blockParameter);
        }


        public Task<string> MsgSenderQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgSenderFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> MsgValueQueryAsync(MsgValueFunction msgValueFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgValueFunction, BigInteger>(msgValueFunction, blockParameter);
        }


        public Task<BigInteger> MsgValueQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgValueFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> WorldQueryAsync(WorldFunction worldFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<WorldFunction, string>(worldFunction, blockParameter);
        }


        public Task<string> WorldQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<WorldFunction, string>(null, blockParameter);
        }

        public Task<string> AttackRequestAsync(AttackFunction attackFunction)
        {
            return ContractHandler.SendRequestAsync(attackFunction);
        }

        public Task<TransactionReceipt> AttackRequestAndWaitForReceiptAsync(AttackFunction attackFunction, CancellationTokenSource cancellationToken = null)
        {
            return ContractHandler.SendRequestAndWaitForReceiptAsync(attackFunction, cancellationToken);
        }

        public Task<string> AttackRequestAsync(byte[] matchEntity, byte[] entity, byte[] target)
        {
            var attackFunction = new AttackFunction();
            attackFunction.MatchEntity = matchEntity;
            attackFunction.Entity = entity;
            attackFunction.Target = target;

            return ContractHandler.SendRequestAsync(attackFunction);
        }

        public Task<TransactionReceipt> AttackRequestAndWaitForReceiptAsync(byte[] matchEntity, byte[] entity, byte[] target, CancellationTokenSource cancellationToken = null)
        {
            var attackFunction = new AttackFunction();
            attackFunction.MatchEntity = matchEntity;
            attackFunction.Entity = entity;
            attackFunction.Target = target;

            return ContractHandler.SendRequestAndWaitForReceiptAsync(attackFunction, cancellationToken);
        }

        public Task<string> MoveOrAttackRequestAsync(MoveOrAttackFunction moveOrAttackFunction)
        {
            return ContractHandler.SendRequestAsync(moveOrAttackFunction);
        }

        public Task<TransactionReceipt> MoveOrAttackRequestAndWaitForReceiptAsync(MoveOrAttackFunction moveOrAttackFunction, CancellationTokenSource cancellationToken = null)
        {
            return ContractHandler.SendRequestAndWaitForReceiptAsync(moveOrAttackFunction, cancellationToken);
        }

        public Task<string> MoveOrAttackRequestAsync(byte[] matchEntity, byte[] entity, List<PositionData> path)
        {
            var moveOrAttackFunction = new MoveOrAttackFunction();
            moveOrAttackFunction.MatchEntity = matchEntity;
            moveOrAttackFunction.Entity = entity;
            moveOrAttackFunction.Path = path;

            return ContractHandler.SendRequestAsync(moveOrAttackFunction);
        }

        public Task<TransactionReceipt> MoveOrAttackRequestAndWaitForReceiptAsync(byte[] matchEntity, byte[] entity, List<PositionData> path, CancellationTokenSource cancellationToken = null)
        {
            var moveOrAttackFunction = new MoveOrAttackFunction();
            moveOrAttackFunction.MatchEntity = matchEntity;
            moveOrAttackFunction.Entity = entity;
            moveOrAttackFunction.Path = path;

            return ContractHandler.SendRequestAndWaitForReceiptAsync(moveOrAttackFunction, cancellationToken);
        }

        public Task<bool> SupportsInterfaceQueryAsync(SupportsInterfaceFunction supportsInterfaceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameter);
        }


        public Task<bool> SupportsInterfaceQueryAsync(byte[] interfaceId, BlockParameter blockParameter = null)
        {
            var supportsInterfaceFunction = new SupportsInterfaceFunction();
            supportsInterfaceFunction.InterfaceId = interfaceId;

            return ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameter);
        }

        public override List<Type> GetAllFunctionTypes()
        {
            return new List<Type>
            {
                typeof(MsgSenderFunction),
                typeof(MsgValueFunction),
                typeof(WorldFunction),
                typeof(AttackFunction),
                typeof(MoveOrAttackFunction),
                typeof(SupportsInterfaceFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(StoreDeleterecordEventDTO),
                typeof(StoreSetrecordEventDTO),
                typeof(StoreSplicestaticdataEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(InvalidActionError),
                typeof(InvalidAttackError),
                typeof(MatchNotActiveError),
                typeof(NotPlayerTurnError),
                typeof(PieceNotOwnedError),
                typeof(SliceOutofboundsError)
            };
        }
    }
}
