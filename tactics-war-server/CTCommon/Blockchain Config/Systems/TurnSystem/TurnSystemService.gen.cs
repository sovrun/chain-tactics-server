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

namespace TacticsWarMud.Systems.TurnSystem
{
    public partial class TurnSystemService: ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, TurnSystemDeployment turnSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<TurnSystemDeployment>().SendRequestAndWaitForReceiptAsync(turnSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, TurnSystemDeployment turnSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<TurnSystemDeployment>().SendRequestAsync(turnSystemDeployment);
        }

        public static async Task<TurnSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, TurnSystemDeployment turnSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, turnSystemDeployment, cancellationTokenSource);
            return new TurnSystemService(web3, receipt.ContractAddress);
        }

        public TurnSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
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

        public Task<string> EndTurnRequestAsync(EndTurnFunction endTurnFunction)
        {
             return ContractHandler.SendRequestAsync(endTurnFunction);
        }

        public Task<TransactionReceipt> EndTurnRequestAndWaitForReceiptAsync(EndTurnFunction endTurnFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(endTurnFunction, cancellationToken);
        }

        public Task<string> EndTurnRequestAsync(byte[] matchEntity)
        {
            var endTurnFunction = new EndTurnFunction();
                endTurnFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAsync(endTurnFunction);
        }

        public Task<TransactionReceipt> EndTurnRequestAndWaitForReceiptAsync(byte[] matchEntity, CancellationTokenSource cancellationToken = null)
        {
            var endTurnFunction = new EndTurnFunction();
                endTurnFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(endTurnFunction, cancellationToken);
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

        public Task<string> SurrenderRequestAsync(SurrenderFunction surrenderFunction)
        {
             return ContractHandler.SendRequestAsync(surrenderFunction);
        }

        public Task<TransactionReceipt> SurrenderRequestAndWaitForReceiptAsync(SurrenderFunction surrenderFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(surrenderFunction, cancellationToken);
        }

        public Task<string> SurrenderRequestAsync(byte[] matchEntity)
        {
            var surrenderFunction = new SurrenderFunction();
                surrenderFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAsync(surrenderFunction);
        }

        public Task<TransactionReceipt> SurrenderRequestAndWaitForReceiptAsync(byte[] matchEntity, CancellationTokenSource cancellationToken = null)
        {
            var surrenderFunction = new SurrenderFunction();
                surrenderFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(surrenderFunction, cancellationToken);
        }

        public override List<Type> GetAllFunctionTypes()
        {
            return new List<Type>
            {
                typeof(MsgSenderFunction),
                typeof(MsgValueFunction),
                typeof(WorldFunction),
                typeof(EndTurnFunction),
                typeof(SupportsInterfaceFunction),
                typeof(SurrenderFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(StoreSetrecordEventDTO),
                typeof(StoreSplicestaticdataEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(NotPlayerTurnError),
                typeof(SliceOutofboundsError),
                typeof(TurnsystemAlreadysurrenderedError),
                typeof(TurnsystemLastremainingplayerError)
            };
        }
    }
}
