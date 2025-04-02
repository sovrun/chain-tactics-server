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

namespace TacticsWarMud.Systems.MatchSystem
{
    public partial class MatchSystemService : ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, MatchSystemDeployment matchSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<MatchSystemDeployment>().SendRequestAndWaitForReceiptAsync(matchSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, MatchSystemDeployment matchSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<MatchSystemDeployment>().SendRequestAsync(matchSystemDeployment);
        }

        public static async Task<MatchSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, MatchSystemDeployment matchSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, matchSystemDeployment, cancellationTokenSource);
            return new MatchSystemService(web3, receipt.ContractAddress);
        }

        public MatchSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
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

        public Task<string> JoinQueueRequestAsync(JoinQueueFunction joinQueueFunction)
        {
            return ContractHandler.SendRequestAsync(joinQueueFunction);
        }

        public Task<TransactionReceipt> JoinQueueRequestAndWaitForReceiptAsync(JoinQueueFunction joinQueueFunction, CancellationTokenSource cancellationToken = null)
        {
            return ContractHandler.SendRequestAndWaitForReceiptAsync(joinQueueFunction, cancellationToken);
        }

        public Task<string> JoinQueueRequestAsync(byte[] boardEntity, byte[] modeEntity)
        {
            var joinQueueFunction = new JoinQueueFunction();
            joinQueueFunction.BoardEntity = boardEntity;
            joinQueueFunction.ModeEntity = modeEntity;

            return ContractHandler.SendRequestAsync(joinQueueFunction);
        }

        public Task<TransactionReceipt> JoinQueueRequestAndWaitForReceiptAsync(byte[] boardEntity, byte[] modeEntity, CancellationTokenSource cancellationToken = null)
        {
            var joinQueueFunction = new JoinQueueFunction();
            joinQueueFunction.BoardEntity = boardEntity;
            joinQueueFunction.ModeEntity = modeEntity;

            return ContractHandler.SendRequestAndWaitForReceiptAsync(joinQueueFunction, cancellationToken);
        }

        public Task<string> LeaveRequestAsync(LeaveFunction leaveFunction)
        {
            return ContractHandler.SendRequestAsync(leaveFunction);
        }

        public Task<string> LeaveRequestAsync()
        {
            return ContractHandler.SendRequestAsync<LeaveFunction>();
        }

        public Task<TransactionReceipt> LeaveRequestAndWaitForReceiptAsync(LeaveFunction leaveFunction, CancellationTokenSource cancellationToken = null)
        {
            return ContractHandler.SendRequestAndWaitForReceiptAsync(leaveFunction, cancellationToken);
        }

        public Task<TransactionReceipt> LeaveRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
            return ContractHandler.SendRequestAndWaitForReceiptAsync<LeaveFunction>(null, cancellationToken);
        }

        public Task<string> SetPlayerReadyAndStartRequestAsync(SetPlayerReadyAndStartFunction setPlayerReadyAndStartFunction)
        {
            return ContractHandler.SendRequestAsync(setPlayerReadyAndStartFunction);
        }

        public Task<TransactionReceipt> SetPlayerReadyAndStartRequestAndWaitForReceiptAsync(SetPlayerReadyAndStartFunction setPlayerReadyAndStartFunction, CancellationTokenSource cancellationToken = null)
        {
            return ContractHandler.SendRequestAndWaitForReceiptAsync(setPlayerReadyAndStartFunction, cancellationToken);
        }

        public Task<string> SetPlayerReadyAndStartRequestAsync(byte[] matchEntity)
        {
            var setPlayerReadyAndStartFunction = new SetPlayerReadyAndStartFunction();
            setPlayerReadyAndStartFunction.MatchEntity = matchEntity;

            return ContractHandler.SendRequestAsync(setPlayerReadyAndStartFunction);
        }

        public Task<TransactionReceipt> SetPlayerReadyAndStartRequestAndWaitForReceiptAsync(byte[] matchEntity, CancellationTokenSource cancellationToken = null)
        {
            var setPlayerReadyAndStartFunction = new SetPlayerReadyAndStartFunction();
            setPlayerReadyAndStartFunction.MatchEntity = matchEntity;

            return ContractHandler.SendRequestAndWaitForReceiptAsync(setPlayerReadyAndStartFunction, cancellationToken);
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
                typeof(JoinQueueFunction),
                typeof(LeaveFunction),
                typeof(SetPlayerReadyAndStartFunction),
                typeof(SupportsInterfaceFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(StoreSetrecordEventDTO),
                typeof(StoreSplicedynamicdataEventDTO),
                typeof(StoreSplicestaticdataEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(EncodedlengthsInvalidlengthError),
                typeof(MatchNotPreparingError),
                typeof(NotInQueueOrMatchError),
                typeof(PlayerAlreadyInQueueError),
                typeof(PlayerAlreadyReadyError),
                typeof(PlayerHasOngoingMatchError),
                typeof(PlayerNotInMatchError),
                typeof(SliceOutofboundsError),
                typeof(StoreIndexoutofboundsError),
                typeof(StoreInvalidresourcetypeError),
                typeof(StoreInvalidspliceError)
            };
        }
    }
}
