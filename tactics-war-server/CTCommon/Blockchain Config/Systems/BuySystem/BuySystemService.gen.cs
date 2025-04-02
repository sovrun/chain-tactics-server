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

namespace TacticsWarMud.Systems.BuySystem
{
    public partial class BuySystemService: ContractWeb3ServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, BuySystemDeployment buySystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<BuySystemDeployment>().SendRequestAndWaitForReceiptAsync(buySystemDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, BuySystemDeployment buySystemDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<BuySystemDeployment>().SendRequestAsync(buySystemDeployment);
        }

        public static async Task<BuySystemService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, BuySystemDeployment buySystemDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, buySystemDeployment, cancellationTokenSource);
            return new BuySystemService(web3, receipt.ContractAddress);
        }

        public BuySystemService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
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

        public Task<string> CommitBuyRequestAsync(CommitBuyFunction commitBuyFunction)
        {
             return ContractHandler.SendRequestAsync(commitBuyFunction);
        }

        public Task<TransactionReceipt> CommitBuyRequestAndWaitForReceiptAsync(CommitBuyFunction commitBuyFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(commitBuyFunction, cancellationToken);
        }

        public Task<string> CommitBuyRequestAsync(byte[] commitHash, byte[] matchEntity)
        {
            var commitBuyFunction = new CommitBuyFunction();
                commitBuyFunction.CommitHash = commitHash;
                commitBuyFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAsync(commitBuyFunction);
        }

        public Task<TransactionReceipt> CommitBuyRequestAndWaitForReceiptAsync(byte[] commitHash, byte[] matchEntity, CancellationTokenSource cancellationToken = null)
        {
            var commitBuyFunction = new CommitBuyFunction();
                commitBuyFunction.CommitHash = commitHash;
                commitBuyFunction.MatchEntity = matchEntity;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(commitBuyFunction, cancellationToken);
        }

        public Task<string> RevealBuyRequestAsync(RevealBuyFunction revealBuyFunction)
        {
             return ContractHandler.SendRequestAsync(revealBuyFunction);
        }

        public Task<TransactionReceipt> RevealBuyRequestAndWaitForReceiptAsync(RevealBuyFunction revealBuyFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(revealBuyFunction, cancellationToken);
        }

        public Task<string> RevealBuyRequestAsync(byte[] matchEntity, List<BigInteger> pieceTypes, byte[] secret)
        {
            var revealBuyFunction = new RevealBuyFunction();
                revealBuyFunction.MatchEntity = matchEntity;
                revealBuyFunction.PieceTypes = pieceTypes;
                revealBuyFunction.Secret = secret;
            
             return ContractHandler.SendRequestAsync(revealBuyFunction);
        }

        public Task<TransactionReceipt> RevealBuyRequestAndWaitForReceiptAsync(byte[] matchEntity, List<BigInteger> pieceTypes, byte[] secret, CancellationTokenSource cancellationToken = null)
        {
            var revealBuyFunction = new RevealBuyFunction();
                revealBuyFunction.MatchEntity = matchEntity;
                revealBuyFunction.PieceTypes = pieceTypes;
                revealBuyFunction.Secret = secret;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(revealBuyFunction, cancellationToken);
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
                typeof(CommitBuyFunction),
                typeof(RevealBuyFunction),
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
                typeof(IncorrectCommitStatusError),
                typeof(IncorrectRevealStatusError),
                typeof(InvalidRevealError),
                typeof(MatchNotActiveError),
                typeof(NoCommitHashError),
                typeof(NotEnoughGoldError),
                typeof(PieceNotAllowedToBuyError),
                typeof(PreparationTimeOverError),
                typeof(EncodedlengthsInvalidlengthError),
                typeof(SliceOutofboundsError),
                typeof(StoreIndexoutofboundsError),
                typeof(StoreInvalidresourcetypeError),
                typeof(StoreInvalidspliceError)
            };
        }
    }
}
