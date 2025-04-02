using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using System.Numerics;

namespace TacticsWarMud.SystemDefinition
{
    public partial class GameBoardSystemDeployment : GameBoardSystemDeploymentBase
    {
        public GameBoardSystemDeployment() : base(BYTECODE) { }
        public GameBoardSystemDeployment(string byteCode) : base(byteCode) { }
    }

    public class GameBoardSystemDeploymentBase : ContractDeploymentMessage
    {
        public static string BYTECODE = "0x6080806040523461001657610d0a908161001c8239f35b600080fdfe6080604052600436101561001257600080fd5b6000803560e01c90816301ffc9a71461006a57508063119df25f146100655780631a9ffd321461006057806345ec93541461005b5763e1af802c1461005657600080fd5b610304565b6102e4565b610185565b61011e565b3461010b57602060031936011261010b57600435907fffffffff00000000000000000000000000000000000000000000000000000000821680920361010b57507fb5dee1270000000000000000000000000000000000000000000000000000000081149081156100e1575b50151560805260206080f35b7f01ffc9a700000000000000000000000000000000000000000000000000000000915014816100d5565b80fd5b600091031261011957565b600080fd5b34610119576000600319360112610119577fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcc36013560601c801561017e575b60209073ffffffffffffffffffffffffffffffffffffffff60405191168152f35b503361015d565b3461011957600319606081360112610119576024356044358060206040516101ac8161036c565b84815201526040519160208301526040820152604081526101cc816103a1565b6101d46103e0565b918251156102df57600435602084015273ffffffffffffffffffffffffffffffffffffffff6102016104fc565b1630810361021657505061021491610541565b005b809291923b156101195761029260006102a2956102b78296604051988997889687957f298314fb0000000000000000000000000000000000000000000000000000000087527f74627461637469637357617200000000426f617264436f6e6669670000000000600488015260a0602488015260a487019061043d565b90838683030160448701526104b0565b90846064850152838203016084840152610471565b03925af180156102da576102c757005b806102d46102149261038d565b8061010e565b6104f0565b6103fa565b34610119576000600319360112610119576020604051601f193601358152f35b3461011957600060031936011261011957602061031f6104fc565b73ffffffffffffffffffffffffffffffffffffffff60405191168152f35b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b6040810190811067ffffffffffffffff82111761038857604052565b61033d565b67ffffffffffffffff811161038857604052565b6060810190811067ffffffffffffffff82111761038857604052565b90601f601f19910116810190811067ffffffffffffffff82111761038857604052565b604051906103ed8261036c565b6001825260203681840137565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b80518210156102df5760209160051b010190565b90815180825260208080930193019160005b82811061045d575050505090565b83518552938101939281019260010161044f565b906060519182815260005b83811061049c5750601f19601f8460006020809697860101520116010190565b80608060209201518282850101520161047c565b919082519283825260005b8481106104dc575050601f19601f8460006020809697860101520116010190565b6020818301810151848301820152016104bb565b6040513d6000823e3d90fd5b7f629a4c26e296b22a8e0856e9f6ecb2d1008d7e00081111962cd175fa7488e1755473ffffffffffffffffffffffffffffffffffffffff168061053e57503390565b90565b604092835192602084017f746273746f72650000000000000000005461626c65730000000000000000000081527f74627461637469637357617200000000426f617264436f6e66696700000000009485878201528681526105a1816103a1565b5190207f86425bff6b57326c7859e89024fe4f238ca327a1ae4a230180dd2f0e88aaa7d91854916105d06108ba565b9060005b82518110156106c4576106386106136105ed8386610429565b517fffffffffffffffffffffffffffffffffffffffffff00000000000000000000001690565b7fffffffffffffffffffffffffffffffffffffffffff00000000000000000000001690565b6001808260581c161461064f575b506001016105d4565b60601c90813b156101195788517f57066c9c0000000000000000000000000000000000000000000000000000000081529160009083908183816106978c8c8f6004850161084f565b03925af19182156102da576001926106b1575b5090610646565b806102d46106be9261038d565b386106aa565b50947f8dbb3a9672eebfd3773e72dd9c102393436816d832c7ba9e1e1ac8fcadcac7a98751806106f5868983610812565b0390a261071061070485610a7a565b83516020850191610b0a565b60ff808460e01c16806107d1575b505060005b81518110156107c85761073c6106136105ed8385610429565b6002808260581c1614610753575b50600101610723565b60601c90813b156101195787517f5b28cdaf00000000000000000000000000000000000000000000000000000000815291600090839081838161079b8b8b8e6004850161084f565b03925af19182156102da576001926107b5575b509061074a565b806102d46107c29261038d565b386107ae565b50505050509050565b60006107dc87610b2b565b55600060805b82848316106107f257505061071e565b6001816108098693610804868d610b68565b610ac5565b920116906107e2565b9061053e9261082c61083a9260808552608085019061043d565b9083820360208501526104b0565b90600060408201526060818303910152610471565b9392916108a16108b59161089360a0947f74627461637469637357617200000000426f617264436f6e6669670000000000895260c060208a015260c089019061043d565b9087820360408901526104b0565b600060608701528581036080870152610471565b930152565b6108c26103e0565b8051156102df57807f74627461637469637357617200000000426f617264436f6e6669670000000000602061053e9301526fffffffffffffffffffffffffffffffff6040516109c86109aa7f3b4102da22e32d82fc925482184f16c09fd4281692720b87d124aef6da48a0f1602084018461093d88836109d4565b0394610951601f19968781018352826103bd565b51902018946040516109778161096b6020820194856109d4565b038681018352826103bd565b5190207f14e2fcc58e58e68ec7edc30c8d50dccc3ce2714a623ec81f46b6a63922d76569185460381c64ffffffffff1690565b916040519260208401958692603f8387010116604052818552610c88565b51169060801b17610c2b565b7f746273746f726500000000000000000053746f7265486f6f6b730000000000008152815160209182019282019160005b828110610a13575050505090565b835185529381019392810192600101610a05565b7f74627461637469637357617200000000426f617264436f6e66696700000000008152815160209182019282019160005b828110610a66575050505090565b835185529381019392810192600101610a58565b604051610a9d81610a8f602082019485610a27565b03601f1981018352826103bd565b5190207f86425bff6b57326c7859e89024fe4f238ca327a1ae4a230180dd2f0e88aaa7d91890565b9060005b6020808210610ae85760018394601f1993945181550193019101610ac9565b5080610af357505050565b6000199060031b1c90818354169119905116179055565b91906020808210610ae85760018394601f1993945181550193019101610ac9565b604051610b4081610a8f602082019485610a27565b5190207f14e2fcc58e58e68ec7edc30c8d50dccc3ce2714a623ec81f46b6a63922d765691890565b919060405160209060208101917f74627461637469637357617200000000426f617264436f6e6669670000000000835260408201602087519197019160005b828110610c1757505050509081610c0a7fff00000000000000000000000000000000000000000000000000000000000000937f3b4102da22e32d82fc925482184f16c09fd4281692720b87d124aef6da48a0f1969703601f1981018352826103bd565b5190209160f81b16181890565b835189529781019792810192600101610ba7565b8060801c9060156fffffffffffffffffffffffffffffffff81921604604051926020906020850160208460051b87010160405283865260005b848110610c745750505050505090565b825182529185019190830190600101610c64565b929091925b602090818410610cae5790600182601f199354875201940192019192610c8d565b919392905080610cbd57505050565b6000199060031b1c9081835116911990541617905256fea264697066735822122009f71960830bbf2101c80b4c1a0358b90cbdda484c2b8c40966bdc9d7d202cc364736f6c63430008180033";
        public GameBoardSystemDeploymentBase() : base(BYTECODE) { }
        public GameBoardSystemDeploymentBase(string byteCode) : base(byteCode) { }

    }

    public partial class SetBoardFunction : SetBoardFunctionBase { }

    [Function("tacticsWar__setBoard")]
    public class SetBoardFunctionBase : FunctionMessage
    {
        [Parameter("bytes32", "gameBoardEntity", 1)]
        public virtual byte[] GameBoardEntity { get; set; }
        [Parameter("uint256", "rows", 2)]
        public virtual BigInteger Rows { get; set; }
        [Parameter("uint256", "columns", 3)]
        public virtual BigInteger Columns { get; set; }
    }
}