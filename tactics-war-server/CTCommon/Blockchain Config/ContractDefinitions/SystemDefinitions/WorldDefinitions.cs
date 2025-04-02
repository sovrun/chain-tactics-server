using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts;
using System.Threading;

namespace TacticsWarMud.SystemDefinition
{
    public partial class MsgSenderFunction : MsgSenderFunctionBase { }

    [Function("_msgSender", "address")]
    public class MsgSenderFunctionBase : FunctionMessage
    {

    }

    public partial class MsgValueFunction : MsgValueFunctionBase { }

    [Function("_msgValue", "uint256")]
    public class MsgValueFunctionBase : FunctionMessage
    {

    }

    public partial class WorldFunction : WorldFunctionBase { }

    [Function("_world", "address")]
    public class WorldFunctionBase : FunctionMessage
    {

    }

    public partial class SupportsInterfaceFunction : SupportsInterfaceFunctionBase { }

    [Function("supportsInterface", "bool")]
    public class SupportsInterfaceFunctionBase : FunctionMessage
    {
        [Parameter("bytes4", "interfaceId", 1)]
        public virtual byte[] InterfaceId { get; set; }
    }

    public partial class SliceOutofboundsError : SliceOutofboundsErrorBase { }

    [Error("Slice_OutOfBounds")]
    public class SliceOutofboundsErrorBase : IErrorDTO
    {
        [Parameter("bytes", "data", 1)]
        public virtual byte[] Data { get; set; }
        [Parameter("uint256", "start", 2)]
        public virtual BigInteger Start { get; set; }
        [Parameter("uint256", "end", 3)]
        public virtual BigInteger End { get; set; }
    }

    public partial class MsgSenderOutputDTO : MsgSenderOutputDTOBase { }

    [FunctionOutput]
    public class MsgSenderOutputDTOBase : IFunctionOutputDTO
    {
        [Parameter("address", "sender", 1)]
        public virtual string Sender { get; set; }
    }

    public partial class MsgValueOutputDTO : MsgValueOutputDTOBase { }

    [FunctionOutput]
    public class MsgValueOutputDTOBase : IFunctionOutputDTO
    {
        [Parameter("uint256", "value", 1)]
        public virtual BigInteger Value { get; set; }
    }

    public partial class WorldOutputDTO : WorldOutputDTOBase { }

    [FunctionOutput]
    public class WorldOutputDTOBase : IFunctionOutputDTO
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class SupportsInterfaceOutputDTO : SupportsInterfaceOutputDTOBase { }

    [FunctionOutput]
    public class SupportsInterfaceOutputDTOBase : IFunctionOutputDTO
    {
        [Parameter("bool", "", 1)]
        public virtual bool ReturnValue1 { get; set; }
    }

    public partial class StoreDeleterecordEventDTO : StoreDeleterecordEventDTOBase { }

    [Event("Store_DeleteRecord")]
    public class StoreDeleterecordEventDTOBase : IEventDTO
    {
        [Parameter("bytes32", "tableId", 1, true)]
        public virtual byte[] TableId { get; set; }
        [Parameter("bytes32[]", "keyTuple", 2, false)]
        public virtual List<byte[]> KeyTuple { get; set; }
    }

    public partial class StoreSetrecordEventDTO : StoreSetrecordEventDTOBase { }

    [Event("Store_SetRecord")]
    public class StoreSetrecordEventDTOBase : IEventDTO
    {
        [Parameter("bytes32", "tableId", 1, true)]
        public virtual byte[] TableId { get; set; }
        [Parameter("bytes32[]", "keyTuple", 2, false)]
        public virtual List<byte[]> KeyTuple { get; set; }
        [Parameter("bytes", "staticData", 3, false)]
        public virtual byte[] StaticData { get; set; }
        [Parameter("bytes32", "encodedLengths", 4, false)]
        public virtual byte[] EncodedLengths { get; set; }
        [Parameter("bytes", "dynamicData", 5, false)]
        public virtual byte[] DynamicData { get; set; }
    }

    public partial class StoreSplicestaticdataEventDTO : StoreSplicestaticdataEventDTOBase { }

    [Event("Store_SpliceStaticData")]
    public class StoreSplicestaticdataEventDTOBase : IEventDTO
    {
        [Parameter("bytes32", "tableId", 1, true)]
        public virtual byte[] TableId { get; set; }
        [Parameter("bytes32[]", "keyTuple", 2, false)]
        public virtual List<byte[]> KeyTuple { get; set; }
        [Parameter("uint48", "start", 3, false)]
        public virtual ulong Start { get; set; }
        [Parameter("bytes", "data", 4, false)]
        public virtual byte[] Data { get; set; }
    }

    public partial class StoreSplicedynamicdataEventDTO : StoreSplicedynamicdataEventDTOBase { }

    [Event("Store_SpliceDynamicData")]
    public class StoreSplicedynamicdataEventDTOBase : IEventDTO
    {
        [Parameter("bytes32", "tableId", 1, true)]
        public virtual byte[] TableId { get; set; }
        [Parameter("bytes32[]", "keyTuple", 2, false)]
        public virtual List<byte[]> KeyTuple { get; set; }
        [Parameter("uint8", "dynamicFieldIndex", 3, false)]
        public virtual byte DynamicFieldIndex { get; set; }
        [Parameter("uint48", "start", 4, false)]
        public virtual ulong Start { get; set; }
        [Parameter("uint40", "deleteCount", 5, false)]
        public virtual ulong DeleteCount { get; set; }
        [Parameter("bytes32", "encodedLengths", 6, false)]
        public virtual byte[] EncodedLengths { get; set; }
        [Parameter("bytes", "data", 7, false)]
        public virtual byte[] Data { get; set; }
    }

    public partial class EncodedlengthsInvalidlengthError : EncodedlengthsInvalidlengthErrorBase { }

    [Error("EncodedLengths_InvalidLength")]
    public class EncodedlengthsInvalidlengthErrorBase : IErrorDTO
    {
        [Parameter("uint256", "length", 1)]
        public virtual BigInteger Length { get; set; }
    }

    public partial class StoreIndexoutofboundsError : StoreIndexoutofboundsErrorBase { }

    [Error("Store_IndexOutOfBounds")]
    public class StoreIndexoutofboundsErrorBase : IErrorDTO
    {
        [Parameter("uint256", "length", 1)]
        public virtual BigInteger Length { get; set; }
        [Parameter("uint256", "accessedIndex", 2)]
        public virtual BigInteger AccessedIndex { get; set; }
    }

    public partial class StoreInvalidresourcetypeError : StoreInvalidresourcetypeErrorBase { }

    [Error("Store_InvalidResourceType")]
    public class StoreInvalidresourcetypeErrorBase : IErrorDTO
    {
        [Parameter("bytes2", "expected", 1)]
        public virtual byte[] Expected { get; set; }
        [Parameter("bytes32", "resourceId", 2)]
        public virtual byte[] ResourceId { get; set; }
        [Parameter("string", "resourceIdString", 3)]
        public virtual string ResourceIdString { get; set; }
    }

    public partial class StoreInvalidspliceError : StoreInvalidspliceErrorBase { }

    [Error("Store_InvalidSplice")]
    public class StoreInvalidspliceErrorBase : IErrorDTO
    {
        [Parameter("uint40", "startWithinField", 1)]
        public virtual ulong StartWithinField { get; set; }
        [Parameter("uint40", "deleteCount", 2)]
        public virtual ulong DeleteCount { get; set; }
        [Parameter("uint40", "fieldLength", 3)]
        public virtual ulong FieldLength { get; set; }
    }
}
