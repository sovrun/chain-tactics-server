using System.Diagnostics;
using System.Numerics;
using Nethereum.Mud.Contracts.World;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;
using TacticsWarMud;
using Nethereum.Hex.HexConvertors.Extensions;
using TacticsWarMud.Tables;
using Nethereum.ABI;
using Nethereum.Util;
using TacticsWarMud.TypeDefinitions;
using Microsoft.AspNetCore.SignalR.Client;
using TacticsWarMud.SystemDefinition;

using static CTCommon.ContractDefines;
using CTCommon;

namespace CTHeadless
{
    public class CTServerContext : CTContext
    {
        // Executable command.
        abstract class ExCommand
        {
            public CTCommon.Command cmd;

            public T GetCommand<T>() where T : CTCommon.Command
            {
                return (T)cmd;
            }

            protected ExCommand(CTCommon.Command cmd_)
            {
                cmd = cmd_;
            }

            public abstract void Execute(CTContext ctx);
            public abstract void Rollback(CTContext ctx);
        };

        class ExAttackCmd : ExCommand
        {
            public ExAttackCmd(CTCommon.Piece attacker, CTCommon.Piece target)
                : base(new CTCommon.AttackCmd(attacker, target))
            {
            }

            public override void Execute(CTContext ctx)
            {
            }

            public override void Rollback(CTContext ctx)
            {
                throw new NotImplementedException();
            }
        };

        class ExMoveCmd : ExCommand
        {
            public List<PositionData> path;
            public ExMoveCmd(CTCommon.Piece piece, List<PositionData> path_)
                : base(new CTCommon.MoveCmd(piece, path_[0], path_[^1]))
            {
                path = path_;
            }

            public override void Execute(CTContext ctx)
            {
                MoveCmd moveCmd = GetCommand<MoveCmd>();
                PositionData endPosition = moveCmd.endPosition;

                CTCommon.Cell? destinationCell = ctx.GetCellAtPosition(endPosition.X, endPosition.Y);
                Debug.Assert(destinationCell != null, "Destination cell not found.");

                lock (ctx.BoardLock)
                {
                    for (int i = 0; i < ctx.Board.Count; i++)
                    {
                        CTCommon.Piece? currentPiece = ctx.Board[i].piece;

                        if (currentPiece == null)
                        {
                            continue;
                        }

                        if (currentPiece.entity.SequenceEqual(moveCmd.piece.entity))
                        {
                            // Move the piece to the destination.
                            destinationCell.piece = currentPiece;

                            // Clear the origin cell.
                            ctx.Board[i].piece = null;

                            return;
                        }
                    }

                }

                Debug.Fail("Piece not found on the board.");
            }

            public override void Rollback(CTContext ctx)
            {
                throw new NotImplementedException();
            }
        };

        class ExEndTurnCmd : ExCommand
        {
            public ExEndTurnCmd(int playerIndex) :
                base(new CTCommon.EndTurnCmd(playerIndex))
            {
            }

            public override void Execute(CTContext ctx)
            {
                EndTurnCmd endTurnCmd = GetCommand<EndTurnCmd>();

                // TODO: 
                //ctx.CurrentPlayerIndex = (endTurnCmd.playerIndex + 1) % 2;
            }

            public override void Rollback(CTContext ctx)
            {
                throw new NotImplementedException();
            }
        };

        public WorldService WorldService { get { return _worldService; } }
        private readonly WorldService _worldService;

        private readonly TacticsNamespace _tctsNamespace;
        private readonly TacticsTableServices _tables;
        private readonly TacticsSystemServices _systems;

        private readonly Web3 _web3;
        private readonly string _worldAddress;
        private readonly Account _account;
        private readonly byte[] _addressAsBytes;

        public byte[] MatchEntity { get { return _matchEntity; } }
        private byte[] _matchEntity = new byte[32];

        private byte[] _matchPlayerEntity = new byte[32];
        private byte[] _opponentPlayerEntity = new byte[32];
        private int _playerIndex = -1;

        private readonly HubConnection _connection;
        private MatchStatusTypes _matchStatus;

        public object CommandsLock = new object();
        private List<ExCommand> MatchCommands { get { return _matchCommands; } }
        private List<ExCommand> _matchCommands;
        private int _lastExecutedCommandIndex;

        public object _errorLock = new object();
        private string _lastError = "";

        public object _receiptLock = new object();
        private TransactionReceipt? _lastReceipt;

        public override int GetPlayerIndex() { return _playerIndex; }

        // TODO: Remove
        public int CurrentPlayerIndex = -1;

        public CTServerContext(string url, string privateKey, string worldAddress, string server_url)
        {
            // Define player.
            _account = new Account(privateKey);
            _addressAsBytes = _account.Address.HexToByteArray();
            Debug.Assert(_account != null, "Must pass valid private key!");

            // Connect to node.
            _web3 = new Web3(_account, url);
            _worldAddress = worldAddress;
            Logger.Log($"World Address: {_worldAddress}");
            Logger.Log($"Player Addrress: {_account.Address}");
            Logger.Log($"Server url: {server_url}");

            // Init nethereum.mud services.
            _worldService = new WorldService(_web3, worldAddress);
            _tctsNamespace = new TacticsNamespace(_web3, worldAddress);
            _tables = _tctsNamespace.Tables;
            _systems = _tctsNamespace.Systems;

            // Connect to web server.
            _connection = new HubConnectionBuilder()
                        .WithUrl(server_url)
                        .Build();

            _matchCommands = new List<ExCommand>();
            _lastExecutedCommandIndex = -1;
        }

        public override string GetMatchEntity()
        {
            return _matchEntity.ToHex();
        }

        public string GetLastError()
        {
            Debug.Assert(_lastError != null, "Attemping to get last error with no errors!");

            lock (_errorLock)
            {
                return _lastError;
            }
        }

        // @returns the receipt of the last succeseful transaction.
        public TransactionReceipt GetLastReceipt()
        {
            Debug.Assert(_lastReceipt != null, "Attemping to get last receipt with no transactions!");

            lock (_receiptLock)
            {
                return _lastReceipt;
            }
        }

        public override async Task GetBalance()
        {
            var balance = await _web3.Eth.GetBalance.SendRequestAsync(_account.Address);
            Logger.Log($"Balance in Wei: {balance.Value}");
        }

        // TODO: Remove
        [Obsolete("Maintained to be compatible with contract v2")]
        public async Task<bool> UpdatePlayerInGameName(string name, CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }
            Logger.Log("Setting player in game name...", Logger.LogLevel.Trace);
            if (!await SafeTransaction(() => _systems.PlayerSystemService.SetPlayerNameRequestAndWaitForReceiptAsync(name)))
            {
                //SmartContractCustomErrorRevertExceptionErrorDecoded revertError = GetLastError();
                //Logger.Log(revertError.Message, Logger.LogLevel.Debug);
                Logger.Log("Error in Update Player Name");
                return false;
            }

            return true;
        }

        // @returns the status of the client.
        public async Task<CTCommon.ContractDefines.PlayerStatusTypes> FindPlayerStatus()
        {
            PlayerStatusTableRecord.PlayerStatusKey playerStatusKey = new PlayerStatusTableRecord.PlayerStatusKey();
            playerStatusKey.PlayerEntity = _addressAsBytes.PadTo32Bytes();

            PlayerStatusTableRecord playerStatusTableRecord = await _tables.PlayerStatusTableService.GetTableRecordAsync(playerStatusKey);

            return (CTCommon.ContractDefines.PlayerStatusTypes)playerStatusTableRecord.Values.Status;
        }

        public override async Task<int> FindMatchWinner()
        {
            if (await GetMatchStatus() != MatchStatusTypes.Finished)
            {
                return -1;
            }

            MatchWinnerTableRecord.MatchWinnerKey key = new MatchWinnerTableRecord.MatchWinnerKey();
            key.MatchEntity = _matchEntity;
            MatchWinnerTableRecord record = await _tables.MatchWinnerTableService.GetTableRecordAsync(key);

            if (key.MatchEntity.SequenceEqual(_matchPlayerEntity)) { return _playerIndex; }
            if (key.MatchEntity.SequenceEqual(_opponentPlayerEntity)) { return (_playerIndex + 1) % 2; }

            return -1;
        }

        public override async Task FindMatch(CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            // Clear match state.
            _matchStatus = MatchStatusTypes.None;
            _matchEntity = new byte[32];
            _matchPlayerEntity = new byte[32];
            _playerIndex = -1;
            _opponentPlayerEntity = new byte[32];

            if (_connection.State == HubConnectionState.Connected)
            {
                await _connection.StopAsync();
            }

            Logger.Log("Joining queue...", Logger.LogLevel.Trace);
            if (!await SafeTransaction(() => _systems.MatchSystemService.JoinQueueRequestAndWaitForReceiptAsync(kBoardEntity.ToBytes32(), kGameModeEntity.ToBytes32())))
            {
                Logger.Log("[Error]: Failed to Join Queue");
                Logger.Log(GetLastError(), Logger.LogLevel.Debug);
            }

            while (true)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                PlayerStatusTableRecord.PlayerStatusKey playerStatusKey = new PlayerStatusTableRecord.PlayerStatusKey();
                playerStatusKey.PlayerEntity = _addressAsBytes.PadTo32Bytes();

                PlayerStatusTableRecord playerStatusTableRecord = await _tables.PlayerStatusTableService.GetTableRecordAsync(playerStatusKey);

                if (playerStatusTableRecord.Values.Status == (byte)PlayerStatusTypes.Queueing) { Logger.Log("Searching for match.."); }

                if (playerStatusTableRecord.Values.Status == (byte)PlayerStatusTypes.Playing)
                {
                    _matchEntity = playerStatusTableRecord.Values.MatchEntity;
                    _matchPlayerEntity = playerStatusTableRecord.Values.MatchPlayerEntity;

                    // Get player index.
                    byte[] mpeBigEndian = new byte[32];
                    Array.Copy(_matchPlayerEntity, mpeBigEndian, 32);
                    Array.Reverse(mpeBigEndian);
                    _playerIndex = BitConverter.ToInt32(mpeBigEndian) - 1;
                    Debug.Assert(!(_playerIndex < 0));

                    // Calculate oponent player entity.
                    _opponentPlayerEntity = BitConverter.GetBytes(((BitConverter.ToUInt32(mpeBigEndian)) % 2) + 1);
                    Array.Reverse(_opponentPlayerEntity);
                    _opponentPlayerEntity = _opponentPlayerEntity.PadTo32Bytes();

                    Logger.Log($"Match found or already exists: {_matchEntity.ToHex()}");
                    Logger.Log($"You are player: {_matchPlayerEntity.ToHex()}");

                    try
                    {
                        // Prepare failsafe leave Fn.
                        LeaveFunction leaveFn = new LeaveFunction();
                        var leaveHandler = _web3.Eth.GetContractTransactionHandler<LeaveFunction>();
                        var estimate = await leaveHandler.EstimateGasAsync(_worldAddress, leaveFn);
                        leaveFn.Gas = estimate.Value;
                        leaveFn.Nonce = 100000;

                        try
                        {
                            await _connection.StartAsync();
                        }
                        catch (Exception ex)
                        {
                            Logger.Log($"Signalr failed to connect!");
                            Logger.Log($"[Error]: {ex.Message}");
                        }

                        if (_connection.State != HubConnectionState.Connected)
                        {
                            await _connection.StopAsync();
                            Logger.Log("[Error]: Failed to start connection");
                            throw new Exception($"Connection failed to start Failed!");
                        }
                        else
                        {
                            Logger.Log("[Success]: Established connection to sequencer!");
                        }

                        string signedLeaveTx = "";
                        try
                        {
                            signedLeaveTx = await leaveHandler.SignTransactionAsync(_worldAddress, leaveFn);
                        }
                        catch (Exception ex)
                        {
                            Logger.Log(ex.Message, Logger.LogLevel.Error);
                            Logger.Log("[Error]: Failed to sign leave transaction!");
                        }

                        Logger.Log(signedLeaveTx, Logger.LogLevel.Info);
                        if (!await _connection.InvokeAsync<bool>("JoinMatch", _matchEntity.ToHex(), signedLeaveTx))
                        {
                            Logger.Log("Failed to connect to server", Logger.LogLevel.Error);
                        }

                        // Subscribe to channels.
                        _connection.On<byte[], List<PositionData>>("OnMove", (piece, path) => { HandleMove(piece, path); });
                        _connection.On<byte[], byte[]>("OnAttack", (attacker, target) => { HandleAttack(attacker, target); });
                        _connection.On<int>("OnEndTurn", (playerIdx) => { HandleEndTurn(playerIdx); });
                        _connection.On<int, string>("OnLeave", (playerIdx, matchEntity) => { HandleLeave(playerIdx, matchEntity); });
                        _connection.On<int>("OnVerifyRequest", (cmdId) => { HandleVerifyRequest(cmdId); });
                    }
                    catch (Exception ex)
                    {
                        Logger.Log(ex.Message, Logger.LogLevel.Error);
                    }

                    break;
                }

                await Task.Delay(kPollingTime, ct);
            }
        }

        public override async Task AcceptMatch(CancellationToken ct = default)
        {
            // Check if already cancelled.
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            // Check if both players have accepted.
            while (true)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                Console.Clear();
                Logger.Log("Waiting for other player to accept match..");

                MatchStatusTableRecord.MatchStatusKey matchStatusKey = new MatchStatusTableRecord.MatchStatusKey();
                matchStatusKey.MatchEntity = _matchEntity;
                MatchStatusTableRecord matchStatusTableRecord = await _tables.MatchStatusTableService.GetTableRecordAsync(matchStatusKey);

                _matchStatus = (MatchStatusTypes)matchStatusTableRecord.Values.Value;

                if (_matchStatus == MatchStatusTypes.Active)
                {
                    Logger.Log($"All players accepted {_matchEntity.ToHex()}!");
                    break;
                }

                if (_matchStatus == MatchStatusTypes.Cancelled)
                {
                    Logger.Log($"Match {_matchEntity.ToHex()} cancelled!");
                    break;
                }

                if (_matchStatus == MatchStatusTypes.Finished)
                {
                    Logger.Log($"Match {_matchEntity.ToHex()} finished!");
                    break;
                }

                Logger.Log("Accepting match...", Logger.LogLevel.Trace);
                if (!await SafeTransaction(() => _systems.MatchSystemService.SetPlayerReadyAndStartRequestAndWaitForReceiptAsync(_matchEntity)))
                {
                    Logger.Log(GetLastError(), Logger.LogLevel.Debug);
                }

                await Task.Delay(kPollingTime, ct);
            }
        }

        public override async Task<bool> SelectUnits(List<BigInteger> selectedUnits, byte[] secret, CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            while (true)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                SpawnStatusTableRecord.SpawnStatusKey key = new SpawnStatusTableRecord.SpawnStatusKey();
                key.MatchEntity = _matchEntity;
                key.PlayerEntity = _matchPlayerEntity;
                SpawnStatusTableRecord? record = await _tables.SpawnStatusTableService.GetTableRecordAsync(key);

                if ((SpawnStatusTypes)record.Values.Value != SpawnStatusTypes.None)
                {
                    return false;
                }

                var encoder = new ABIEncode();
                var encodedData = encoder.GetABIEncoded(new ABIValue("uint256[]", selectedUnits), new ABIValue("bytes32", secret));
                var sha3 = new Sha3Keccack();
                byte[] unitsHash = sha3.CalculateHash(encodedData);

                Logger.Log("Commiting buy...", Logger.LogLevel.Trace);
                if (!await SafeTransaction(() => _systems.BuySystemService.CommitBuyRequestAndWaitForReceiptAsync(unitsHash, _matchEntity)))
                {
                    Logger.Log(GetLastError(), Logger.LogLevel.Debug);
                }
                else
                {
                    return true;
                }

                await Task.Delay(kPollingTime, ct);
            }
        }

        public override async Task<bool> RevealUnits(List<BigInteger> selectedUnits, byte[] secret, CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            while (true)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                SpawnStatusTableRecord.SpawnStatusKey key = new SpawnStatusTableRecord.SpawnStatusKey();
                key.MatchEntity = _matchEntity;
                key.PlayerEntity = _matchPlayerEntity;
                SpawnStatusTableRecord record = await SafeQuery<SpawnStatusTableRecord>(() => _tables.SpawnStatusTableService.GetTableRecordAsync(key));

                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.RevealBuying)
                {
                    Logger.Log("Revealing buy...", Logger.LogLevel.Trace);
                    if (!await SafeTransaction(() => _systems.BuySystemService.RevealBuyRequestAndWaitForReceiptAsync(_matchEntity, selectedUnits, secret)))
                    {
                        Logger.Log(GetLastError(), Logger.LogLevel.Debug);
                    }
                }

                if ((SpawnStatusTypes)record.Values.Value >= SpawnStatusTypes.CommitSpawning)
                {
                    using (new Profiler("Querying client pieces"))
                    {
                        InventoryTableRecord.InventoryKey inventoryKey = new InventoryTableRecord.InventoryKey();
                        inventoryKey.MatchEntity = _matchEntity;
                        inventoryKey.PlayerEntity = _matchPlayerEntity;
                        InventoryTableRecord inventoryRecord = await SafeQuery<InventoryTableRecord>(() => _tables.InventoryTableService.GetTableRecordAsync(inventoryKey));

                        playersPieces[_playerIndex] = new List<CTCommon.Piece>();
                        foreach (byte[] piece in inventoryRecord.Values.Pieces)
                        {
                            PieceTableRecord.PieceKey pieceKey = new PieceTableRecord.PieceKey();
                            pieceKey.MatchEntity = _matchEntity;
                            pieceKey.Entity = piece;
                            PieceTableRecord pieceRecord = await SafeQuery<PieceTableRecord>(() => _tables.PieceTableService.GetTableRecordAsync(pieceKey));

                            PieceType type = (PieceType)((int)pieceRecord.Values.Value);
                            playersPieces[_playerIndex].Add(new CTCommon.Piece(type, piece, _playerIndex));
                        }
                    }

                    using (new Profiler("Querying opponent pieces."))
                    {
                        InventoryTableRecord.InventoryKey inventoryKey = new InventoryTableRecord.InventoryKey();
                        inventoryKey.MatchEntity = _matchEntity;
                        inventoryKey.PlayerEntity = _opponentPlayerEntity;
                        InventoryTableRecord inventoryRecord = await SafeQuery<InventoryTableRecord>(() => _tables.InventoryTableService.GetTableRecordAsync(inventoryKey));

                        playersPieces[(_playerIndex + 1) % 2] = new List<CTCommon.Piece>();
                        foreach (byte[] piece in inventoryRecord.Values.Pieces)
                        {
                            PieceTableRecord.PieceKey pieceKey = new PieceTableRecord.PieceKey();
                            pieceKey.MatchEntity = _matchEntity;
                            pieceKey.Entity = piece;
                            PieceTableRecord pieceRecord = await SafeQuery<PieceTableRecord>(() => _tables.PieceTableService.GetTableRecordAsync(pieceKey));

                            PieceType type = (PieceType)((int)pieceRecord.Values.Value);
                            playersPieces[(_playerIndex + 1) % 2].Add(new CTCommon.Piece(type, piece, (_playerIndex + 1) % 2));
                        }
                    }

                    return true;
                }

                await Task.Delay(kPollingTime, ct);
            }
        }

        public override async Task SpawnUnits(List<BigInteger> selectedUnits, List<PositionData> playerPositions, byte[] secret, CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            // TODO:  Make conditional
            FlushCommands();

            // TODO: Move to serverContexSyncBoard

            List<PositionData> positions = new List<PositionData>();
            for (int i = 0; i < playerPositions.Count; i++) { positions.Add(playerPositions[i].AsPlayer(_playerIndex)); }

            while (!ct.IsCancellationRequested)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                SpawnStatusTableRecord.SpawnStatusKey key = new SpawnStatusTableRecord.SpawnStatusKey();
                key.MatchEntity = _matchEntity;
                key.PlayerEntity = _matchPlayerEntity;
                SpawnStatusTableRecord record = await SafeQuery<SpawnStatusTableRecord>(() => _tables.SpawnStatusTableService.GetTableRecordAsync(key));

                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.CommitSpawning)
                {
                    // Select spawn positions.
                    List<byte[]> entities = new();
                    foreach (CTCommon.Piece piece in playersPieces[_playerIndex]) { entities.Add(piece.entity); }
                    byte[] spawnHash = await SafeQuery<byte[]>(() => _systems.ViewSystemService.GenerateSpawnCommitHashQueryAsync(positions, entities, secret));

                    Logger.Log("Commiting spawn...", Logger.LogLevel.Trace);
                    if (!await SafeTransaction(() => _systems.SpawnSystemService.CommitSpawnRequestAndWaitForReceiptAsync(spawnHash, _matchEntity)))
                    {
                        Logger.Log(GetLastError(), Logger.LogLevel.Debug);
                    }
                }

                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.RevealSpawning)
                {
                    foreach (var position in positions) { Logger.Log($"{position.X},{position.Y}"); }

                    List<byte[]> entities = new();
                    foreach (CTCommon.Piece piece in playersPieces[_playerIndex]) { entities.Add(piece.entity); }

                    Logger.Log("Revealing spawn...", Logger.LogLevel.Trace);
                    if (!await SafeTransaction(() => _systems.SpawnSystemService.RevealSpawnRequestAndWaitForReceiptAsync(_matchEntity, positions, entities, secret)))
                    {
                        Logger.Log(GetLastError(), Logger.LogLevel.Debug);
                    }
                }

                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.Ready)
                {
                    MatchPlayersTableRecord.MatchPlayersKey matchPlayersKey = new MatchPlayersTableRecord.MatchPlayersKey();
                    matchPlayersKey.MatchEntity = _matchEntity;
                    MatchPlayersTableRecord matchPlayersRecord = await SafeQuery<MatchPlayersTableRecord>(() => _tables.MatchPlayersTableService.GetTableRecordAsync(matchPlayersKey));

                    Debug.Assert(matchPlayersRecord.Values.Value.Count > 0);
                    CurrentPlayerIndex = matchPlayersRecord.Values.Value[0].SequenceEqual(_matchPlayerEntity) ? _playerIndex : (_playerIndex + 1) % 2;

                    await SyncBoard();
                    return;
                }

                await Task.Delay(kPollingTime, ct);
            }
        }

        public override int GetCurrentPlayerIndex()
        {
            return CurrentPlayerIndex;
        }

        public override async Task<bool> Move(CTCommon.Piece piece, List<PositionData> path)
        {
            try
            {
                int cmdId = await _connection.InvokeAsync<int>((string)nameof(CTCommon.CommandType.Move), _matchEntity.ToHex(), piece.entity, path);
                return true;
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message);
                return false;
            }
        }

        public override async Task<bool> Attack(CTCommon.Piece piece, CTCommon.Piece target)
        {
            try
            {
                int cmdId = await _connection.InvokeAsync<int>((string)nameof(CTCommon.CommandType.Attack), _matchEntity.ToHex(), piece.entity, target.entity);
                return true;
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message);
                return false;
            }
        }

        public override async Task EndTurn()
        {
            try
            {
                await _connection.InvokeAsync<int>((string)nameof(CTCommon.CommandType.EndTurn), _matchEntity.ToHex(), _playerIndex);
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message);
            }
        }

        public override async Task<bool> Leave(CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            if (await GetMatchStatus() == MatchStatusTypes.None)
            {
                return true;
            }

            if (!await SafeTransaction(() => _systems.MatchSystemService.LeaveRequestAndWaitForReceiptAsync(), 1))
            {
                Logger.Log(GetLastError(), Logger.LogLevel.Debug);
                return false;
            }

            return true;
        }

        //@brief Blocks until current match is in sync with blockchain.
        public async Task WaitForBlockChainSync(CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            while (!ct.IsCancellationRequested)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                try
                {
                    if (await _connection.InvokeAsync<bool>("QueryBlockChainSync", _matchEntity.ToHex()))
                    {
                        break;
                    }
                }
                catch (Exception ex)
                {
                    Logger.Log(ex.Message);
                }

                await Task.Delay(3000);
            }
        }

        public async Task<bool> LeaveSync(CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                throw new TaskCanceledException();
            }

            // TODO: Catch server disconnections
            if (_connection.State != HubConnectionState.Connected)
            {
                await _connection.StopAsync();
                throw new Exception("Connection start Async Failed!");
            }

            while (!ct.IsCancellationRequested)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                try
                {
                    if (await _connection.InvokeAsync<bool>((string)nameof(CTCommon.CommandType.Leave), _matchEntity.ToHex(), _playerIndex))
                    {
                        if (!await SafeTransaction(() => _systems.MatchSystemService.LeaveRequestAndWaitForReceiptAsync(), 1))
                        {
                            Logger.Log(GetLastError(), Logger.LogLevel.Debug);
                            return false;
                        }

                        return true;
                    }
                }
                catch (Exception ex)
                {
                    Logger.Log(ex.Message);
                }

                await Task.Delay(3000);
            }

            return false;
        }

        public override async Task SyncBoard()
        {
            // TODO:
            try
            {
                FlushCommands();
            }
            catch (Exception)
            {
                // Client has disconnected. 
            }

            // Full clear board.
            using (new Profiler("Querying client pieces"))
            {
                InventoryTableRecord.InventoryKey inventoryKey = new InventoryTableRecord.InventoryKey();
                inventoryKey.MatchEntity = _matchEntity;
                inventoryKey.PlayerEntity = _matchPlayerEntity;
                InventoryTableRecord inventoryRecord = await SafeQuery<InventoryTableRecord>(() => _tables.InventoryTableService.GetTableRecordAsync(inventoryKey));

                playersPieces[_playerIndex] = new List<CTCommon.Piece>();
                foreach (byte[] piece in inventoryRecord.Values.Pieces)
                {
                    PieceTableRecord.PieceKey pieceKey = new PieceTableRecord.PieceKey();
                    pieceKey.MatchEntity = _matchEntity;
                    pieceKey.Entity = piece;

                    PieceTableRecord pieceRecord = await _tables.PieceTableService.GetTableRecordAsync(pieceKey);
                    PieceType type = (PieceType)((int)pieceRecord.Values.Value);
                    playersPieces[_playerIndex].Add(new CTCommon.Piece(type, piece, _playerIndex));
                }
            }

            using (new Profiler("Querying opponent pieces."))
            {
                InventoryTableRecord.InventoryKey inventoryKey = new InventoryTableRecord.InventoryKey();
                inventoryKey.MatchEntity = _matchEntity;
                inventoryKey.PlayerEntity = _opponentPlayerEntity;
                InventoryTableRecord inventoryRecord = await SafeQuery<InventoryTableRecord>(() => _tables.InventoryTableService.GetTableRecordAsync(inventoryKey));

                playersPieces[(_playerIndex + 1) % 2] = new List<CTCommon.Piece>();
                foreach (byte[] piece in inventoryRecord.Values.Pieces)
                {
                    PieceTableRecord.PieceKey pieceKey = new PieceTableRecord.PieceKey();
                    pieceKey.MatchEntity = _matchEntity;
                    pieceKey.Entity = piece;

                    PieceTableRecord pieceRecord = await _tables.PieceTableService.GetTableRecordAsync(pieceKey);
                    PieceType type = (PieceType)((int)pieceRecord.Values.Value);
                    playersPieces[(_playerIndex + 1) % 2].Add(new CTCommon.Piece(type, piece, (_playerIndex + 1) % 2));
                }
            }

            // ~ Update board ~
            using (new Profiler("Querying piece data."))
            {
                foreach (CTCommon.Piece piece in playersPieces[_playerIndex])
                {
                    PositionTableRecord.PositionKey positionKey = new PositionTableRecord.PositionKey();
                    positionKey.MatchEntity = _matchEntity;
                    positionKey.Entity = piece.entity;
                    PositionTableRecord positionRecord = await SafeQuery<PositionTableRecord>(() => _tables.PositionTableService.GetTableRecordAsync(positionKey));

                    GetCellAtPosition(positionRecord.Values.X, positionRecord.Values.Y).piece = piece;
                }

                foreach (CTCommon.Piece piece in playersPieces[(_playerIndex + 1) % 2])
                {
                    PositionTableRecord.PositionKey positionKey = new PositionTableRecord.PositionKey();
                    positionKey.MatchEntity = _matchEntity;
                    positionKey.Entity = piece.entity;
                    PositionTableRecord positionRecord = await SafeQuery<PositionTableRecord>(() => _tables.PositionTableService.GetTableRecordAsync(positionKey));

                    GetCellAtPosition(positionRecord.Values.X, positionRecord.Values.Y).piece = piece;
                }
            }
        }

        // @returns the status of the current match and none if match does not exist.
        public override async Task<MatchStatusTypes> GetMatchStatus()
        {
            if (_matchStatus == MatchStatusTypes.None)
            {
                MatchStatusTableRecord.MatchStatusKey matchStatusKey = new MatchStatusTableRecord.MatchStatusKey();
                matchStatusKey.MatchEntity = _matchEntity;

                MatchStatusTableRecord matchStatusTableRecord = await _tables.MatchStatusTableService.GetTableRecordAsync(matchStatusKey);
                _matchStatus = (MatchStatusTypes)matchStatusTableRecord.Values.Value;
            }

            return _matchStatus;
        }

        private void HandleMove(byte[] pieceEntity, List<PositionData> path)
        {
            Debug.Assert(path.Count > 0, "Invalid path");

            lock (BoardLock)
            {
                foreach (CTCommon.Cell cell in Board)
                {
                    if (cell.piece == null)
                    {
                        continue;
                    }

                    if (cell.piece.entity.SequenceEqual(pieceEntity))
                    {
                        lock (CommandsLock)
                        {
                            _matchCommands.Add(new ExMoveCmd(cell.piece, path));
                        }

                        return;
                    }
                }
            }

            Debug.Fail("Piece not found on the board.");
        }

        private async void HandleAttack(byte[] attackerEntity, byte[] targetEntity)
        {
            CTCommon.Piece? attacker = null;
            CTCommon.Piece? target = null;

            foreach (CTCommon.Cell cell in Board)
            {
                if (cell.piece == null)
                {
                    continue;
                }

                if (cell.piece.entity.SequenceEqual(attackerEntity))
                {
                    attacker = cell.piece;
                    continue;
                }

                if (cell.piece.entity.SequenceEqual(targetEntity))
                {
                    target = cell.piece;
                    continue;
                }
            }

            Debug.Assert(attacker != null, "Invalid attacker!");
            Debug.Assert(target != null, "Invalid target!");

            if (target.type == PieceType.Fortress)
            {
                MatchStatusTableRecord.MatchStatusKey matchStatusKey = new MatchStatusTableRecord.MatchStatusKey();
                matchStatusKey.MatchEntity = _matchEntity;

                MatchStatusTableRecord matchStatusTableRecord = await _tables.MatchStatusTableService.GetTableRecordAsync(matchStatusKey);
                _matchStatus = (MatchStatusTypes)matchStatusTableRecord.Values.Value;
            }

            lock (CommandsLock)
            {
                _matchCommands.Add(new ExAttackCmd(attacker, target));
            }
        }

        private void HandleLeave(int playerIdx, string matchEntity)
        {
            if (_matchStatus > MatchStatusTypes.Pending && _matchStatus < MatchStatusTypes.Finished)
            {
                _matchStatus = MatchStatusTypes.Finished;
            }
            else
            {
                _matchStatus = MatchStatusTypes.Cancelled;
            }

            RaiseLeave(playerIdx, matchEntity);
        }

        private void HandleEndTurn(int playerIdx)
        {
            lock (CommandsLock)
            {
                _matchCommands.Add(new ExEndTurnCmd(playerIdx));
            }
        }

        private async void HandleVerifyRequest(int cmdId)
        {
            ExCommand exCmd = _matchCommands[cmdId];
            bool success = false;

            Logger.Log($"{cmdId} requesting verification.", Logger.LogLevel.Trace);
            try
            {
                switch (exCmd.cmd.type)
                {
                    case (CTCommon.CommandType.Move):
                        ExMoveCmd exMoveCmd = (ExMoveCmd)_matchCommands[cmdId];
                        MoveCmd moveCmd = exMoveCmd.GetCommand<MoveCmd>();
                        success = await SafeTransaction(() => _systems.MoveSystemService.MoveRequestAndWaitForReceiptAsync(_matchEntity, moveCmd.piece.entity, exMoveCmd.path), 1);
                        break;

                    case (CTCommon.CommandType.Attack):
                        AttackCmd attackCmd = exCmd.GetCommand<AttackCmd>();
                        success = await SafeTransaction(() => _systems.CombatSystemService.AttackRequestAndWaitForReceiptAsync(_matchEntity, attackCmd.attacker.entity, attackCmd.target.entity), 1);
                        break;
                    case (CTCommon.CommandType.EndTurn):
                        success = await SafeTransaction(() => _systems.TurnSystemService.EndTurnRequestAndWaitForReceiptAsync(_matchEntity), 1);
                        break;
                    default:
                        break;
                }

                if (success)
                {
                    Logger.Log($"Verifying {cmdId}. ", Logger.LogLevel.Trace);
                    await _connection.InvokeAsync("Verify", _matchEntity.ToHex(), cmdId, GetLastReceipt().TransactionHash);
                }
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message);
            }
        }

        // @brief Executes all queued command and raises callbacks.
        // @note Should be called before each render.
        public void FlushCommands()
        {
            lock (CommandsLock)
            {
                for (int i = _lastExecutedCommandIndex + 1; i < _matchCommands.Count; i++)
                {
                    ExCommand exCmd = _matchCommands[++_lastExecutedCommandIndex];

                    try
                    {
                        exCmd.Execute(this);
                        switch (exCmd.cmd.type)
                        {
                            case (CTCommon.CommandType.Attack):
                                AttackCmd attackCmd = exCmd.GetCommand<AttackCmd>();
                                RaiseAttack(attackCmd.attacker, attackCmd.target);
                                break;
                            case (CTCommon.CommandType.Move):
                                ExMoveCmd moveCmd = (ExMoveCmd)exCmd;
                                RaiseMove(moveCmd.GetCommand<MoveCmd>().piece, moveCmd.path);
                                break;
                            case (CTCommon.CommandType.EndTurn):
                                EndTurnCmd endTurnCmd = exCmd.GetCommand<EndTurnCmd>();
                                RaiseEndTurn(endTurnCmd.playerIndex);
                                break;
                            default:
                                break;
                        }
                    }
                    catch (TaskCanceledException)
                    {
                        Logger.Log($"{exCmd.cmd.type} was canceled.");
                    }
                    catch (Exception ex)
                    {
                        Logger.Log(ex.Message);
                    }
                }
            }
        }

        private async Task<Record> SafeQuery<Record>(Func<Task<Record>> queryCall)
        {
            try
            {
                return await queryCall();
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message, Logger.LogLevel.Error);
                Debug.Assert(false, "Failed to query. Check if key is valid!");
                return default;
            }
        }

        // @brief Handles the execution of smart contract transactions.
        // @note On rever exception, you can call GetLastError() to get the exception.
        // @returns True if successeful. False if there was  a revert exception.
        private async Task<bool> SafeTransaction(Func<Task<TransactionReceipt>> contractCall, int maxAttempts = 5, CancellationToken ct = default)
        {
            if (ct.IsCancellationRequested)
            {
                new TaskCanceledException();
            }

            for (int attempt = 0; attempt < maxAttempts; attempt++)
            {
                if (ct.IsCancellationRequested)
                {
                    new TaskCanceledException();
                }

                try
                {
                    TransactionReceipt tr = await contractCall();

                    if (tr.Failed(true))
                    {
                        Logger.Log($"Transaction failed. Attempt {attempt + 1} out of {maxAttempts}.", Logger.LogLevel.Trace);
                        tr.HasErrors();
                        continue;
                    }

                    lock (_receiptLock)
                    {
                        _lastReceipt = tr;
                    }

                    return true;
                }
                /*catch (SmartContractCustomErrorRevertException ex)*/
                /*{*/
                /*    var fullError = _tctsNamespace.FindCustomErrorException(ex);*/
                /**/
                /*    lock (_errorLock)*/
                /*    {*/
                /*        _lastError = fullError.Message;*/
                /*    }*/
                /**/
                /*    await Task.Delay(kPollingTime);*/
                /*    return false;*/
                /*}*/
                catch (Exception ex)
                {
                    lock (_errorLock)
                    {
                        _lastError = ex.Message;
                    }

                    await Task.Delay(kPollingTime);
                    return false;
                }
            }

            Logger.Log("Max attempts reached!", Logger.LogLevel.Error);
            return false;
        }
    }
}
