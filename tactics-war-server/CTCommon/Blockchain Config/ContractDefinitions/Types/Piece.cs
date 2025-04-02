using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;

namespace TacticsWarMud.TypeDefinitions
{
    public partial class Piece : PieceBase { }

    public class PieceBase
    {
        [Parameter("uint256", "cost", 1)]
        public virtual BigInteger Cost { get; set; }
        [Parameter("uint256", "health", 2)]
        public virtual BigInteger Health { get; set; }
        [Parameter("uint256", "damage", 3)]
        public virtual BigInteger Damage { get; set; }
        [Parameter("uint256", "attackType", 4)]
        public virtual BigInteger AttackType { get; set; }
        [Parameter("uint256", "range", 5)]
        public virtual BigInteger Range { get; set; }
        [Parameter("uint256", "blindspot", 6)]
        public virtual BigInteger Blindspot { get; set; }
        [Parameter("uint256", "movement", 7)]
        public virtual BigInteger Movement { get; set; }
    }
}
