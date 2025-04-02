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

namespace TacticsWarMud.Systems.MoveSystem
{
    public partial class MoveSystemService: ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, MoveSystemDeployment moveSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<MoveSystemDeployment>().SendRequestAndWaitForReceiptAsync(moveSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, MoveSystemDeployment moveSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<MoveSystemDeployment>().SendRequestAsync(moveSystemDeployment);
        }

        public static async Task<MoveSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, MoveSystemDeployment moveSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, moveSystemDeployment, cancellationTokenSource);
            return new MoveSystemService(web3, receipt.ContractAddress);
        }

        public MoveSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
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

        public Task<string> MoveRequestAsync(MoveFunction moveFunction)
        {
             return ContractHandler.SendRequestAsync(moveFunction);
        }

        public Task<TransactionReceipt> MoveRequestAndWaitForReceiptAsync(MoveFunction moveFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(moveFunction, cancellationToken);
        }

        public Task<string> MoveRequestAsync(byte[] matchEntity, byte[] entity, List<PositionData> path)
        {
            var moveFunction = new MoveFunction();
                moveFunction.MatchEntity = matchEntity;
                moveFunction.Entity = entity;
                moveFunction.Path = path;
            
             return ContractHandler.SendRequestAsync(moveFunction);
        }

        public Task<TransactionReceipt> MoveRequestAndWaitForReceiptAsync(byte[] matchEntity, byte[] entity, List<PositionData> path, CancellationTokenSource cancellationToken = null)
        {
            var moveFunction = new MoveFunction();
                moveFunction.MatchEntity = matchEntity;
                moveFunction.Entity = entity;
                moveFunction.Path = path;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(moveFunction, cancellationToken);
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
                typeof(MoveFunction),
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
                typeof(ExceededMovesAllowedError),
                typeof(InvalidMoveError),
                typeof(InvalidPathError),
                typeof(MatchNotActiveError),
                typeof(NotPlayerTurnError),
                typeof(NotSelectedPieceError),
                typeof(PieceNotExistsError),
                typeof(PieceNotOwnedError),
                typeof(PositionOccupiedError),
                typeof(SliceOutofboundsError)
            };
        }
    }
}
