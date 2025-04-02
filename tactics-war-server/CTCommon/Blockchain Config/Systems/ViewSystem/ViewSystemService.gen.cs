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

namespace TacticsWarMud.Systems.ViewSystem
{
    public partial class ViewSystemService: ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, ViewSystemDeployment viewSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<ViewSystemDeployment>().SendRequestAndWaitForReceiptAsync(viewSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, ViewSystemDeployment viewSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<ViewSystemDeployment>().SendRequestAsync(viewSystemDeployment);
        }

        public static async Task<ViewSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, ViewSystemDeployment viewSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, viewSystemDeployment, cancellationTokenSource);
            return new ViewSystemService(web3, receipt.ContractAddress);
        }

        public ViewSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
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

        public Task<byte[]> GenerateBuyCommitHashQueryAsync(GenerateBuyCommitHashFunction generateBuyCommitHashFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GenerateBuyCommitHashFunction, byte[]>(generateBuyCommitHashFunction, blockParameter);
        }

        
        public Task<byte[]> GenerateBuyCommitHashQueryAsync(List<BigInteger> pieceTypes, byte[] secret, BlockParameter blockParameter = null)
        {
            var generateBuyCommitHashFunction = new GenerateBuyCommitHashFunction();
                generateBuyCommitHashFunction.PieceTypes = pieceTypes;
                generateBuyCommitHashFunction.Secret = secret;
            
            return ContractHandler.QueryAsync<GenerateBuyCommitHashFunction, byte[]>(generateBuyCommitHashFunction, blockParameter);
        }

        public Task<byte[]> GenerateSpawnCommitHashQueryAsync(GenerateSpawnCommitHashFunction generateSpawnCommitHashFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GenerateSpawnCommitHashFunction, byte[]>(generateSpawnCommitHashFunction, blockParameter);
        }

        
        public Task<byte[]> GenerateSpawnCommitHashQueryAsync(List<PositionData> coordinates, List<byte[]> pieceEntities, byte[] secret, BlockParameter blockParameter = null)
        {
            var generateSpawnCommitHashFunction = new GenerateSpawnCommitHashFunction();
                generateSpawnCommitHashFunction.Coordinates = coordinates;
                generateSpawnCommitHashFunction.PieceEntities = pieceEntities;
                generateSpawnCommitHashFunction.Secret = secret;
            
            return ContractHandler.QueryAsync<GenerateSpawnCommitHashFunction, byte[]>(generateSpawnCommitHashFunction, blockParameter);
        }

        public Task<List<byte[]>> GetMatchPlayersQueryAsync(GetMatchPlayersFunction getMatchPlayersFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetMatchPlayersFunction, List<byte[]>>(getMatchPlayersFunction, blockParameter);
        }

        
        public Task<List<byte[]>> GetMatchPlayersQueryAsync(byte[] matchEntity, BlockParameter blockParameter = null)
        {
            var getMatchPlayersFunction = new GetMatchPlayersFunction();
                getMatchPlayersFunction.MatchEntity = matchEntity;
            
            return ContractHandler.QueryAsync<GetMatchPlayersFunction, List<byte[]>>(getMatchPlayersFunction, blockParameter);
        }

        public Task<GetPieceOutputDTO> GetPieceQueryAsync(GetPieceFunction getPieceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<GetPieceFunction, GetPieceOutputDTO>(getPieceFunction, blockParameter);
        }

        public Task<GetPieceOutputDTO> GetPieceQueryAsync(BigInteger pieceType, BlockParameter blockParameter = null)
        {
            var getPieceFunction = new GetPieceFunction();
                getPieceFunction.PieceType = pieceType;
            
            return ContractHandler.QueryDeserializingToObjectAsync<GetPieceFunction, GetPieceOutputDTO>(getPieceFunction, blockParameter);
        }

        public Task<List<byte[]>> GetPieceEntitiesQueryAsync(GetPieceEntitiesFunction getPieceEntitiesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetPieceEntitiesFunction, List<byte[]>>(getPieceEntitiesFunction, blockParameter);
        }

        
        public Task<List<byte[]>> GetPieceEntitiesQueryAsync(byte[] matchEntity, byte[] playerEntity, BlockParameter blockParameter = null)
        {
            var getPieceEntitiesFunction = new GetPieceEntitiesFunction();
                getPieceEntitiesFunction.MatchEntity = matchEntity;
                getPieceEntitiesFunction.PlayerEntity = playerEntity;
            
            return ContractHandler.QueryAsync<GetPieceEntitiesFunction, List<byte[]>>(getPieceEntitiesFunction, blockParameter);
        }

        public Task<List<byte[]>> GetPieceEntitiesByAddressQueryAsync(GetPieceEntitiesByAddressFunction getPieceEntitiesByAddressFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetPieceEntitiesByAddressFunction, List<byte[]>>(getPieceEntitiesByAddressFunction, blockParameter);
        }

        
        public Task<List<byte[]>> GetPieceEntitiesByAddressQueryAsync(byte[] matchEntity, BlockParameter blockParameter = null)
        {
            var getPieceEntitiesByAddressFunction = new GetPieceEntitiesByAddressFunction();
                getPieceEntitiesByAddressFunction.MatchEntity = matchEntity;
            
            return ContractHandler.QueryAsync<GetPieceEntitiesByAddressFunction, List<byte[]>>(getPieceEntitiesByAddressFunction, blockParameter);
        }

        public Task<byte> GetSpawnStatusQueryAsync(GetSpawnStatusFunction getSpawnStatusFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetSpawnStatusFunction, byte>(getSpawnStatusFunction, blockParameter);
        }

        
        public Task<byte> GetSpawnStatusQueryAsync(byte[] matchEntity, byte[] playerEntity, BlockParameter blockParameter = null)
        {
            var getSpawnStatusFunction = new GetSpawnStatusFunction();
                getSpawnStatusFunction.MatchEntity = matchEntity;
                getSpawnStatusFunction.PlayerEntity = playerEntity;
            
            return ContractHandler.QueryAsync<GetSpawnStatusFunction, byte>(getSpawnStatusFunction, blockParameter);
        }

        public Task<byte> GetSpawnStatusByAddressQueryAsync(GetSpawnStatusByAddressFunction getSpawnStatusByAddressFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetSpawnStatusByAddressFunction, byte>(getSpawnStatusByAddressFunction, blockParameter);
        }

        
        public Task<byte> GetSpawnStatusByAddressQueryAsync(byte[] matchEntity, BlockParameter blockParameter = null)
        {
            var getSpawnStatusByAddressFunction = new GetSpawnStatusByAddressFunction();
                getSpawnStatusByAddressFunction.MatchEntity = matchEntity;
            
            return ContractHandler.QueryAsync<GetSpawnStatusByAddressFunction, byte>(getSpawnStatusByAddressFunction, blockParameter);
        }

        public Task<string> GetPlayerInGameNameQueryAsync(GetPlayerInGameNameFunction getPlayerInGameNameFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetPlayerInGameNameFunction, string>(getPlayerInGameNameFunction, blockParameter);
        }

        
        public virtual Task<string> GetPlayerInGameNameQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetPlayerInGameNameFunction, string>(null, blockParameter);
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
                typeof(GenerateBuyCommitHashFunction),
                typeof(GenerateSpawnCommitHashFunction),
                typeof(GetMatchPlayersFunction),
                typeof(GetPieceFunction),
                typeof(GetPieceEntitiesFunction),
                typeof(GetPieceEntitiesByAddressFunction),
                typeof(GetSpawnStatusFunction),
                typeof(GetSpawnStatusByAddressFunction),
                typeof(SupportsInterfaceFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {

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
