using System.Numerics;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.ContractHandlers;
using TacticsWarMud.SystemDefinition;
using System.Threading.Tasks;
using System.Threading;
using System;
using System.Collections.Generic;

namespace TacticsWarMud.Systems.PlayerSystem
{
    public partial class PlayerSystemService: PlayerSystemServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, PlayerSystemDeployment playerSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<PlayerSystemDeployment>().SendRequestAndWaitForReceiptAsync(playerSystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, PlayerSystemDeployment playerSystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<PlayerSystemDeployment>().SendRequestAsync(playerSystemDeployment);
        }

        public static async Task<PlayerSystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, PlayerSystemDeployment playerSystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, playerSystemDeployment, cancellationTokenSource);
            return new PlayerSystemService(web3, receipt.ContractAddress);
        }

        public PlayerSystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

    }


    public partial class PlayerSystemServiceBase: ContractWeb3ServiceBase
    {

        public PlayerSystemServiceBase(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

        public Task<string> MsgSenderQueryAsync(MsgSenderFunction msgSenderFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgSenderFunction, string>(msgSenderFunction, blockParameter);
        }

        
        public virtual Task<string> MsgSenderQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgSenderFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> MsgValueQueryAsync(MsgValueFunction msgValueFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgValueFunction, BigInteger>(msgValueFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> MsgValueQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MsgValueFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> WorldQueryAsync(WorldFunction worldFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<WorldFunction, string>(worldFunction, blockParameter);
        }

        
        public virtual Task<string> WorldQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<WorldFunction, string>(null, blockParameter);
        }

        public virtual Task<string> SetPlayerNameRequestAsync(SetPlayerNameFunction setPlayerNameFunction)
        {
             return ContractHandler.SendRequestAsync(setPlayerNameFunction);
        }

        public virtual Task<TransactionReceipt> SetPlayerNameRequestAndWaitForReceiptAsync(SetPlayerNameFunction setPlayerNameFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setPlayerNameFunction, cancellationToken);
        }

        public virtual Task<string> SetPlayerNameRequestAsync(string name)
        {
            var setPlayerNameFunction = new SetPlayerNameFunction();
                setPlayerNameFunction.Name = name;
            
             return ContractHandler.SendRequestAsync(setPlayerNameFunction);
        }

        public virtual Task<TransactionReceipt> SetPlayerNameRequestAndWaitForReceiptAsync(string name, CancellationTokenSource cancellationToken = null)
        {
            var setPlayerNameFunction = new SetPlayerNameFunction();
                setPlayerNameFunction.Name = name;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setPlayerNameFunction, cancellationToken);
        }

        public Task<bool> SupportsInterfaceQueryAsync(SupportsInterfaceFunction supportsInterfaceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameter);
        }

        
        public virtual Task<bool> SupportsInterfaceQueryAsync(byte[] interfaceId, BlockParameter blockParameter = null)
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
                typeof(SetPlayerNameFunction),
                typeof(SupportsInterfaceFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(StoreSplicedynamicdataEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(EmptyPlayerNameError),
                typeof(EncodedlengthsInvalidlengthError),
                typeof(SliceOutofboundsError),
                typeof(StoreIndexoutofboundsError),
                typeof(StoreInvalidresourcetypeError),
                typeof(StoreInvalidspliceError)
            };
        }
    }
}
