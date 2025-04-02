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

namespace TacticsWarMud.Systems.GameBoardSystem
{
    public partial class GameBoardSystemService: ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, GameBoardSystemDeployment gameBoardSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<GameBoardSystemDeployment>().SendRequestAndWaitForReceiptAsync(gameBoardSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, GameBoardSystemDeployment gameBoardSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<GameBoardSystemDeployment>().SendRequestAsync(gameBoardSystemDeployment);
        }

        public static async Task<GameBoardSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, GameBoardSystemDeployment gameBoardSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, gameBoardSystemDeployment, cancellationTokenSource);
            return new GameBoardSystemService(web3, receipt.ContractAddress);
        }

        public GameBoardSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
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

        public Task<string> SetBoardRequestAsync(SetBoardFunction setBoardFunction)
        {
             return ContractHandler.SendRequestAsync(setBoardFunction);
        }

        public Task<TransactionReceipt> SetBoardRequestAndWaitForReceiptAsync(SetBoardFunction setBoardFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setBoardFunction, cancellationToken);
        }

        public Task<string> SetBoardRequestAsync(byte[] gameBoardEntity, BigInteger rows, BigInteger columns)
        {
            var setBoardFunction = new SetBoardFunction();
                setBoardFunction.GameBoardEntity = gameBoardEntity;
                setBoardFunction.Rows = rows;
                setBoardFunction.Columns = columns;
            
             return ContractHandler.SendRequestAsync(setBoardFunction);
        }

        public Task<TransactionReceipt> SetBoardRequestAndWaitForReceiptAsync(byte[] gameBoardEntity, BigInteger rows, BigInteger columns, CancellationTokenSource cancellationToken = null)
        {
            var setBoardFunction = new SetBoardFunction();
                setBoardFunction.GameBoardEntity = gameBoardEntity;
                setBoardFunction.Rows = rows;
                setBoardFunction.Columns = columns;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setBoardFunction, cancellationToken);
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
                typeof(SetBoardFunction),
                typeof(SupportsInterfaceFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(StoreSetrecordEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(SliceOutofboundsError)
            };
        }
    }
}
