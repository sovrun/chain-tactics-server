using Microsoft.AspNetCore.SignalR;
using TacticsWarMud.TypeDefinitions;

namespace CTServer.Hubs
{
    public class CTHub : Hub
    {
        public async Task<bool> JoinMatch(string matchEntityId, string txHash)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, matchEntityId);
            return true;
        }

        public async Task<int> Move(string matchEntity, byte[] pieceEntity, List<PositionData> path)
        {
            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.Move), pieceEntity, path);
            return 0;
        }

        public async Task<int> Attack(string matchEntity, byte[] attackerEntity, byte[] targetEntity)
        {
            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.Attack), attackerEntity, targetEntity);
            return 0;
        }

        public async Task<int> EndTurn(string matchEntity, int playerIndex)
        {
            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.EndTurn), playerIndex);
            return 0;
        }

        public async Task<bool> Leave(string matchEntity, int playerIndex)
        {
            await Clients.Group(matchEntity).SendAsync(GetCallbackFnName(CTCommon.CommandType.Leave), playerIndex);
            return true;
        }

        public static string GetCallbackFnName(CTCommon.CommandType actionType)
        {
            return $"On{actionType.ToString()}";
        }
    }
}
