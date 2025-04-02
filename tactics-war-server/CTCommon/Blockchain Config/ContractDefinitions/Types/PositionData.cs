using Nethereum.ABI.FunctionEncoding.Attributes;

namespace TacticsWarMud.TypeDefinitions
{
    public partial class PositionData : PositionDataBase { }

    public class PositionDataBase
    {
        [Parameter("uint32", "x", 1)]
        public virtual uint X { get; set; }
        [Parameter("uint32", "y", 2)]
        public virtual uint Y { get; set; }
    }
}
