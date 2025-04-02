using Nethereum.Mud;
using Nethereum.Mud.Contracts.Core.Namespaces;
using Nethereum.Web3;

namespace TacticsWarMud
{
    public class TacticsNamespaceResource : NamespaceResource
    {
        public TacticsNamespaceResource() : base(String.Empty)
        {
        }
    }
    public class TacticsNamespace : NamespaceBase<TacticsNamespaceResource, TacticsSystemServices, TacticsTableServices>
    {
        public TacticsNamespace(IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
            Tables = new TacticsTableServices(web3, contractAddress);
            Systems = new TacticsSystemServices(web3, contractAddress);
        }
    }
}
