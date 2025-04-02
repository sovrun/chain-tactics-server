using CTServer.Hubs;
using Microsoft.AspNetCore.SignalR;
using CTCommon;

using Nethereum.Web3;

namespace CTSequencerHub.Services
{
    public class ChainSyncBackgroundService : BackgroundService
    {
        private readonly ILogger<ChainSyncBackgroundService> _logger;
        private readonly IHubContext<CTServer.Hubs.CTSequencerHub> _hubContext;

        public ChainSyncBackgroundService(ILogger<ChainSyncBackgroundService> logger, IHubContext<CTServer.Hubs.CTSequencerHub> hubContext)
        {
            _logger = logger;
            _hubContext = hubContext;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Chain Sync Background Service running.");

            while (!stoppingToken.IsCancellationRequested)
            {
                await SyncMatchesToChain();

                await Task.Delay(TimeSpan.FromSeconds(2), stoppingToken);
            }

            Logger.LogFn = (string msg, Logger.LogLevel logLevel) =>
            {
                switch (logLevel)
                {
                    case Logger.LogLevel.Info:
                        Console.WriteLine(msg);
                        break;
                    case Logger.LogLevel.Debug:
                    case Logger.LogLevel.Trace:
                        break;
                    default:
                        break;
                }
            };
        }

        private async Task SyncMatchesToChain()
        {
            foreach (var kvp in CTServer.Hubs.CTSequencerHub.sMatches)
            {
                string matchEntity = kvp.Key;

                int toValidate = CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].validatedCommandIndex;

                if (CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].networkCommands.Count <= 0)
                {
                    continue;
                }

                if (CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].IsSynced())
                {
                    continue;
                }

                NetworkCommand cmd = CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].networkCommands[toValidate];

                if (CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].validationAttempts < CTServer.Hubs.CTSequencerHub.kMaxVerifyRequests)
                {
                    CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].validationAttempts++;

                    try
                    {
                        await _hubContext.Clients.Client(cmd.callerId).SendAsync("OnVerifyRequest", cmd.cmdId);
                        continue;
                    }
                    catch (Exception ex)
                    {
                        Logger.Log($"Client disconnected. {ex.Message}", Logger.LogLevel.Debug);
                    }
                }

                // Fail if max validation requests reached on current command.
                Web3 web3 = new Web3(CTServer.Hubs.CTSequencerHub.rpcUrl);
                int unresponsiveIndex = CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].players.FindIndex(player => player.connectionId == cmd.callerId);
                try
                {
                    await web3.Eth.Transactions.SendRawTransaction.SendRequestAsync(CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].players[unresponsiveIndex].signedLeaveTx);
                }
                catch (Exception ex)
                {
                    Logger.Log(ex.Message, Logger.LogLevel.Error);
                }
                finally
                {
                    Logger.Log("Player disconnected. Force Leave!", Logger.LogLevel.Debug);
                    CTServer.Hubs.CTSequencerHub.sMatches[matchEntity].validatedCommandIndex = Int32.MaxValue;

                    await _hubContext.Clients.Group(matchEntity).SendAsync(CTServer.Hubs.CTSequencerHub.GetCallbackFnName(CTCommon.CommandType.Leave), unresponsiveIndex, matchEntity);
                }
            }
        }
    }
}
