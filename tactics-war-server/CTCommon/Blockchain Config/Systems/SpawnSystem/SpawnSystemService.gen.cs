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
using TacticsWarMud.TypeDefinitions;
using TacticsWarMud.SystemDefinition;

namespace TacticsWarMud.Systems.SpawnSystem
{
    public partial class SpawnSystemService: ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, SpawnSystemDeployment spawnSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<SpawnSystemDeployment>().SendRequestAndWaitForReceiptAsync(spawnSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, SpawnSystemDeployment spawnSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<SpawnSystemDeployment>().SendRequestAsync(spawnSystemDeployment);
        }

        public static async Task<SpawnSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, SpawnSystemDeployment spawnSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, spawnSystemDeployment, cancellationTokenSource);
            return new SpawnSystemService(web3, receipt.ContractAddress);
        }

        public SpawnSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
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

        public Task<string> CommitSpawnRequestAsync(CommitSpawnFunction commitSpawnFunction)
        {
             return ContractHandler.SendRequestAsync(commitSpawnFunction);
        }

        public Task<TransactionReceipt> CommitSpawnRequestAndWaitForReceiptAsync(CommitSpawnFunction commitSpawnFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(commitSpawnFunction, cancellationToken);
        }

        public Task<string> CommitSpawnRequestAsync(byte[] commitHash, byte[] matchEntity)
        {
            var commitSpawnFunction = new CommitSpawnFunction();
                commitSpawnFunction.CommitHash = commitHash;
                commitSpawnFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAsync(commitSpawnFunction);
        }

        public Task<TransactionReceipt> CommitSpawnRequestAndWaitForReceiptAsync(byte[] commitHash, byte[] matchEntity, CancellationTokenSource cancellationToken = null)
        {
            var commitSpawnFunction = new CommitSpawnFunction();
                commitSpawnFunction.CommitHash = commitHash;
                commitSpawnFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(commitSpawnFunction, cancellationToken);
        }

        public Task<string> RevealSpawnRequestAsync(RevealSpawnFunction revealSpawnFunction)
        {
             return ContractHandler.SendRequestAsync(revealSpawnFunction);
        }

        public Task<TransactionReceipt> RevealSpawnRequestAndWaitForReceiptAsync(RevealSpawnFunction revealSpawnFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(revealSpawnFunction, cancellationToken);
        }

        public Task<string> RevealSpawnRequestAsync(byte[] matchEntity, List<PositionData> coordinates, List<byte[]> pieceEntities, byte[] secret)
        {
            var revealSpawnFunction = new RevealSpawnFunction();
                revealSpawnFunction.MatchEntity = matchEntity;
                revealSpawnFunction.Coordinates = coordinates;
                revealSpawnFunction.PieceEntities = pieceEntities;
                revealSpawnFunction.Secret = secret;
            
             return ContractHandler.SendRequestAsync(revealSpawnFunction);
        }

        public Task<TransactionReceipt> RevealSpawnRequestAndWaitForReceiptAsync(byte[] matchEntity, List<PositionData> coordinates, List<byte[]> pieceEntities, byte[] secret, CancellationTokenSource cancellationToken = null)
        {
            var revealSpawnFunction = new RevealSpawnFunction();
                revealSpawnFunction.MatchEntity = matchEntity;
                revealSpawnFunction.Coordinates = coordinates;
                revealSpawnFunction.PieceEntities = pieceEntities;
                revealSpawnFunction.Secret = secret;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(revealSpawnFunction, cancellationToken);
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
                typeof(CommitSpawnFunction),
                typeof(RevealSpawnFunction),
                typeof(SupportsInterfaceFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(StoreDeleterecordEventDTO),
                typeof(StoreSetrecordEventDTO),
                typeof(StoreSplicedynamicdataEventDTO),
                typeof(StoreSplicestaticdataEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(CoordinateNotAllowedError),
                typeof(EncodedlengthsInvalidlengthError),
                typeof(IncorrectCommitStatusError),
                typeof(IncorrectRevealStatusError),
                typeof(InvalidRevealError),
                typeof(MatchNotActiveError),
                typeof(NoCommitHashError),
                typeof(NotInSpawnAreaError),
                typeof(PositionOccupiedError),
                typeof(PreparationTimeOverError),
                typeof(SliceOutofboundsError),
                typeof(StoreIndexoutofboundsError),
                typeof(StoreInvalidresourcetypeError),
                typeof(StoreInvalidspliceError)
            };
        }
    }
}
