using System.Diagnostics;
using System.Numerics;
using TacticsWarMud.TypeDefinitions;

namespace CTCommon
{
    /*@brief Disposable style profiler that logs elapsed time of disposable scope.*/
    public class Profiler : IDisposable
    {

        public Profiler(string name)
        {
            _name = name;
            _stopwatch = Stopwatch.StartNew();
        }

        public void Dispose()
        {
            _stopwatch.Stop();
            Console.WriteLine($"[{_name}] Elapsed time: {_stopwatch.ElapsedMilliseconds} ms");
        }

        private readonly Stopwatch _stopwatch;
        private readonly string _name;
    }

    // ~ Util ~
    public static class BigIntegerExtensions
    {
        public static byte[] ToBytes32(this BigInteger bigInteger, bool swapEndianness = true)
        {
            byte[] unpaddedByte = bigInteger.ToByteArray();
            if (swapEndianness)
            {
                Array.Reverse(unpaddedByte);
            }

            if (unpaddedByte.Length > 32)
            {
                Console.WriteLine("[Error]: Converting a BigInteger that is bigger than 32 bytes.");
                return new byte[0];
            }

            byte[] paddedBytes = new byte[32];
            Array.Copy(unpaddedByte, 0, paddedBytes, 32 - unpaddedByte.Length, unpaddedByte.Length);
            return paddedBytes;
        }
    }

    public static class PositionDataExtensions
    {
        public static PositionData AsPlayer(this PositionData position, int playerIndex)
        {
            if (playerIndex == 0) { return position; }

            const uint boardSize = 9;
            uint flippedX = (boardSize + 1) - position.X;
            uint flippedY = (boardSize + 1) - position.Y;
            return new PositionData { X = flippedX, Y = flippedY };
        }
    }

    public static class StringExtensions
    {
        public static string Bytes32ToEthereumAddress(byte[] bytes32)
        {
            if (bytes32 == null || bytes32.Length != 32)
            {
                throw new ArgumentException("Input must be a 32-byte array.");
            }

            // Ethereum address is the last 20 bytes of the 32-byte array
            byte[] addressBytes = bytes32.Skip(12).ToArray();

            // Convert to a hex string and prepend with "0x"
            string address = "0x" + BitConverter.ToString(addressBytes).Replace("-", "").ToLower();

            return address;
        }

        public static byte[] EthereumAddressToBytes32(string address)
        {
            if (!address.StartsWith("0x") || address.Length != 42)
            {
                throw new ArgumentException("Input must be a valid Ethereum address.");
            }

            // Remove the "0x" prefix
            address = address.Substring(2);

            // Convert the address from hex to byte array
            byte[] addressBytes = Enumerable.Range(0, address.Length)
                                    .Where(x => x % 2 == 0)
                                    .Select(x => Convert.ToByte(address.Substring(x, 2), 16))
                                    .ToArray();

            // Create a 32-byte array and copy the address bytes to the end
            byte[] bytes32 = new byte[32];
            Array.Copy(addressBytes, 0, bytes32, 12, 20);

            return bytes32;
        }
    }
}
