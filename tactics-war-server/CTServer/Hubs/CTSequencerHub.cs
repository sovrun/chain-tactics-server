using System.Collections.Concurrent;
using Microsoft.AspNetCore.SignalR;
using TacticsWarMud.TypeDefinitions;
using Nethereum.Signer;
using CTCommon;

namespace CTServer.Hubs
{
    public struct Player
    {
        public string address;
        public string connectionId;
        public string signedLeaveTx;
    }

    public class Match
    {
        public Match() { }

        public bool IsSynced()
        {
            return validatedCommandIndex >= networkCommands.Count;
        }

        public int validatedCommandIndex = 0;
        public int validationAttempts = 0;

        public List<Player> players = new List<Player>();

        public List<NetworkCommand> networkCommands = new List<NetworkCommand>();
    };

    public class NetworkCommand
    {
        public Command cmd;
        public string callerId;
        public int cmdId;

        public NetworkCommand(string connectionId, int commandId, Command command)
        {
            callerId = connectionId;
            cmdId = commandId;
            cmd = command;
        }
    };

    public class CTSequencerHub : Hub
    {
        public const int kVerifyInterval = 0;
        public const int kMaxVerifyRequests = 15;

        public static string rpcUrl = "";
        public static ConcurrentDictionary<string, Match> sMatches = new ConcurrentDictionary<string, Match>();

        public CTSequencerHub(IConfiguration configuration)
        {
            rpcUrl = configuration["RPCUrl"] ?? "https://sovrun-testchain.rpc.caldera.xyz/http";
            Console.WriteLine($"RPC URL in CTSequencerHub: {rpcUrl}");
        }

        public async Task<bool> JoinMatch(string matchEntity, string signedLeaveTx)
        {
            string playerAddress = "";
            try
            {
                playerAddress = TransactionVerificationAndRecovery.GetSenderAddress(signedLeaveTx);
                Logger.Log($"Client joining: {playerAddress}", Logger.LogLevel.Trace);
            }
            catch (Exception ex)
            {
                Logger.Log($"Failed to join: {ex.Message}", Logger.LogLevel.Error);
                return false;
            }

            if (!sMatches.ContainsKey(matchEntity))
            {
                Logger.Log($"New match: {matchEntity}", Logger.LogLevel.Trace);
                sMatches[matchEntity] = new Match();
            }

            await Groups.AddToGroupAsync(Context.ConnectionId, matchEntity);

            int reconnectingIndex = sMatches[matchEntity].players.FindIndex(player => player.address == playerAddress);
            if (reconnectingIndex >= 0)
            {
                sMatches[matchEntity].players[reconnectingIndex] = new Player
                {
                    address = playerAddress,
                    connectionId = Context.ConnectionId,
                    signedLeaveTx = signedLeaveTx
                };

                Logger.Log($"Client reconnected: {playerAddress}", Logger.LogLevel.Trace);
                return true;
            }

            sMatches[matchEntity].players.Add(new Player
            {
                address = playerAddress,
                connectionId = Context.ConnectionId,
                signedLeaveTx = signedLeaveTx
            });

            return true;
        }

        public async Task<int> Move(string matchEntity, byte[] pieceEntity, List<PositionData> path)
        {
            if (!sMatches.ContainsKey(matchEntity))
            {
                return -1;
            }

            int cmdId = sMatches[matchEntity].networkCommands.Count;

            CTCommon.Piece piece = new CTCommon.Piece();
            piece.entity = pieceEntity;

            sMatches[matchEntity].networkCommands.Add(new NetworkCommand(Context.ConnectionId, cmdId, new MoveCmd(piece, path[0], path[^1])));

            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.Move), pieceEntity, path);

            Logger.Log($"Command: {cmdId}.", Logger.LogLevel.Debug);
            return cmdId;
        }

        public async Task<int> Attack(string matchEntity, byte[] attackerEntity, byte[] targetEntity)
        {
            if (!sMatches.ContainsKey(matchEntity))
            {
                return -1;
            }

            int cmdId = sMatches[matchEntity].networkCommands.Count;

            CTCommon.Piece attacker = new CTCommon.Piece();
            attacker.entity = attackerEntity;

            CTCommon.Piece target = new CTCommon.Piece();
            target.entity = targetEntity;

            sMatches[matchEntity].networkCommands.Add(new NetworkCommand(Context.ConnectionId, cmdId, new AttackCmd(attacker, target)));

            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.Attack), attackerEntity, targetEntity);

            Logger.Log($"Command: {cmdId}.", Logger.LogLevel.Debug);
            return cmdId;
        }

        public async Task<int> EndTurn(string matchEntity, int playerIndex)
        {
            if (!sMatches.ContainsKey(matchEntity))
            {
                return -1;
            }

            int cmdId = sMatches[matchEntity].networkCommands.Count;

            sMatches[matchEntity].networkCommands.Add(new NetworkCommand(Context.ConnectionId, cmdId, new EndTurnCmd(playerIndex)));

            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.EndTurn), playerIndex);

            Logger.Log($"Command: {cmdId}.", Logger.LogLevel.Debug);
            return cmdId;
        }

        //@ Brief returns true if leave was succeseful.
        public async Task<bool> Leave(string matchEntity, int playerIndex)
        {
            if (!sMatches.ContainsKey(matchEntity))
            {
                return false;
            }

            if (!sMatches[matchEntity].IsSynced())
            {
                return false;
            }

            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.Leave), playerIndex, matchEntity);
            await MatchEnd(matchEntity);

            Logger.Log($"Match: {matchEntity} has ended.", Logger.LogLevel.Debug);
            return true;
        }

        public void Verify(string matchEntity, int cmdId, string txHash)
        {
            // TODO: Validate hash w command.
            if (!sMatches.ContainsKey(matchEntity))
            {
                return;
            }

            sMatches[matchEntity].validatedCommandIndex++;
            sMatches[matchEntity].validationAttempts = 0;
            Logger.Log($"Verified: {cmdId} : {txHash}. {sMatches[matchEntity].networkCommands.Count - (cmdId + 1)} cmds left.", Logger.LogLevel.Trace);
        }

        //@returns true if match is sync with blockchain succeseful.
        //@returns false if match is NOT sync with blockchain succeseful or match does not exist.
        public async Task<bool> QueryBlockChainSync(string matchEntity)
        {
            if (!sMatches.ContainsKey(matchEntity))
            {
                return false;
            }

            await Task.Delay(0);

            return sMatches[matchEntity].IsSynced();
        }

        public async Task<List<Command>> QueryMatchCommands(string matchEntity)
        {
            if (!sMatches.ContainsKey(matchEntity))
            {
                return new List<Command>();
            }

            await Task.Delay(0);

            List<Command> commands = new List<Command>();
            foreach (var networkCmd in sMatches[matchEntity].networkCommands)
            {
                commands.Add(networkCmd.cmd);
            }

            return commands;
        }

        private static async Task MatchEnd(string matchEntity)
        {
            if (sMatches.TryRemove(matchEntity, out Match? removedMatch))
            {
            }

            await Task.Delay(0);
        }

        public static string GetCallbackFnName(CTCommon.CommandType actionType)
        {
            return $"On{actionType.ToString()}";
        }
    }
}

