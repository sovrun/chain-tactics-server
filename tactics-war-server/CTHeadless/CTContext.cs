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
using static CTCommon.ContractDefines;
using CTCommon;
using Nethereum.Contracts;

namespace CTHeadless
{
    public abstract class CTContext
    {
        public const int kPollingTime = 100;

        public const int kBoardW = 9;
        public const int kBoardH = 9;
        public static readonly BigInteger kBoardEntity = 1;
        public static readonly BigInteger kGameModeEntity = 2;

        public string GetLastError()
        {
            /*Debug.Assert(_lastError != null, "Attemping to get last error with no errors!");*/
            /**/
            /*lock (_errorLock)*/
            /*{*/
            /*    return _lastError;*/
            /*}*/
            return "";
        }

        public object BoardLock = new object();

        public IReadOnlyList<CTCommon.Cell> Board { get { return _board.AsReadOnly(); } }
        protected List<CTCommon.Cell> _board = new List<CTCommon.Cell>();

        public List<List<CTCommon.Piece>> PlayerPieces { get { return playersPieces; } }
        protected List<List<CTCommon.Piece>> playersPieces = new List<List<CTCommon.Piece>>() { new List<CTCommon.Piece>(), new List<CTCommon.Piece>() };

        public Dictionary<CTCommon.Piece, CTCommon.Cell> PieceToCell = new Dictionary<CTCommon.Piece, CTCommon.Cell>();

        /// @note Called before Board is updated.
        public event Action<CTCommon.Piece, List<PositionData>>? OnMove;

        /// @note Called before Board is updated.
        public event Action<CTCommon.Piece, CTCommon.Piece>? OnAttack;

        public event Action<int>? OnEndTurn;

        public event Action<int, string>? OnLeave;

        protected void RaiseMove(CTCommon.Piece piece, List<PositionData> path) { OnMove?.Invoke(piece, path); }

        protected void RaiseAttack(CTCommon.Piece attacker, CTCommon.Piece target) { OnAttack?.Invoke(attacker, target); }

        protected void RaiseEndTurn(int playerIdx) { OnEndTurn?.Invoke(playerIdx); }

        protected void RaiseLeave(int playerIdx, string matchEntity) { OnLeave?.Invoke(playerIdx, matchEntity); }

        public CTContext()
        {
            for (int i = 0; i < kBoardW * kBoardH; i++) { _board.Add(new CTCommon.Cell()); }
        }

        public CTCommon.Cell GetCellAtPosition(uint x, uint y)
        {
            Debug.Assert(x > 0 && y > 0, "Values must be in range > 1");

            lock (BoardLock)
            {
                return Board[(int)((y - 1) * kBoardW + (x - 1))];
            }
        }

        static public int GetCellIndexAtPosition(uint x, uint y)
        {
            Debug.Assert(x > 0 && y > 0, "Values must be in range > 1");
            return (int)((y - 1) * kBoardW + (x - 1));
        }

        /// @return Match entity of the current game.
        public abstract string GetMatchEntity();

        /// @return Index of client player.
        public abstract int GetPlayerIndex();

        /// @return Index of active player.
        public abstract int GetCurrentPlayerIndex();

        /// @return The balance of the active player.
        public abstract Task GetBalance();

        /*@brief Attempts find returns when accepted. */
        /*@note After this succeeds match entity will be available*/
        public abstract Task FindMatch(CancellationToken ct = default);

        public virtual Task<bool> Spectate(string privateKey, CancellationToken ct = default) { return Task.FromResult(false); }

        /*@brief Accepts match find returns when accepted. */
        /*@ note Must be called after FindMatch*/
        public abstract Task AcceptMatch(CancellationToken ct = default);

        public abstract Task<bool> SelectUnits(List<BigInteger> selectedUnits, byte[] secret, CancellationToken ct = default);

        /*@brief Reveals units to opponent 
         *@ note Guarantees the PlayerPieces are populated. */
        public abstract Task<bool> RevealUnits(List<BigInteger> selectedUnits, byte[] secret, CancellationToken ct = default);

        public abstract Task SpawnUnits(List<BigInteger> selectedUnits, List<PositionData> positions, byte[] secret, CancellationToken ct = default);

        public abstract Task<bool> Move(CTCommon.Piece piece, List<PositionData> path);

        public abstract Task<bool> Attack(CTCommon.Piece piece, CTCommon.Piece target);

        public abstract Task EndTurn();

        public abstract Task<bool> Leave(CancellationToken ct = default);

        /// @brief Performs a hard query of the entire board state.
        /// @note This is very slow and should only be called on reconnection or extreme desync.
        public abstract Task SyncBoard();

        public abstract Task<MatchStatusTypes> GetMatchStatus();

        // @returns The index of the winner of the match or -1 if the match has no winner.
        public abstract Task<int> FindMatchWinner();
    }

    public class CTRawContext : CTContext
    {
        private readonly WorldService _worldService;
        private readonly TacticsNamespace _tctsNamespace;
        private readonly TacticsTableServices _tables;
        private readonly TacticsSystemServices _systems;

        private readonly Web3 _web3;
        private readonly Account _account;
        private readonly byte[] _addressAsBytes;

        private byte[] _matchEntity = new byte[32];
        private byte[] _matchPlayerEntity = new byte[32];
        private byte[] _opponentPlayerEntity = new byte[32];
        private int _playerIndex = -1;

        private int _currentPlayerIndex = 0;
        private BigInteger _lastMoveTimeStamp = new(0);

        public CTRawContext(string url, string privateKey, string worldAddress)
        {
            // Define player.
            _account = new Account(privateKey);
            _addressAsBytes = _account.Address.HexToByteArray();
            Debug.Assert(_account != null, "Must pass valid private key!");

            // Connect to node.
            _web3 = new Web3(_account, url);
            Logger.Log($"World Address: {worldAddress}");
            Logger.Log($"Player: {_account.Address}");

            // Init nethereum.mud services.
            _worldService = new WorldService(_web3, worldAddress);
            _tctsNamespace = new TacticsNamespace(_web3, worldAddress);
            _tables = _tctsNamespace.Tables;
            _systems = _tctsNamespace.Systems;

            // Set up board.
            for (int i = 0; i < kBoardW * kBoardH; i++) { _board.Add(new CTCommon.Cell()); }
        }

        public override int GetPlayerIndex() { return _playerIndex; }

        public override string GetMatchEntity()
        {
            return _matchEntity.ToHex();
        }

        public override int GetCurrentPlayerIndex()
        {
            return _currentPlayerIndex;
        }

        public override async Task<int> FindMatchWinner()
        {
            if (await GetMatchStatus() != MatchStatusTypes.Finished)
            {
                return -1;
            }

            MatchWinnerTableRecord.MatchWinnerKey key = new MatchWinnerTableRecord.MatchWinnerKey();
            key.MatchEntity = _matchEntity;

            MatchWinnerTableRecord? record = await SafeContractCall<MatchWinnerTableRecord>(() =>
                _tables.MatchWinnerTableService.GetTableRecordAsync(key),
                "MatchWinnerTableService.GetTableRecordAsync");

            Debug.Assert(record != null);

            if (key.MatchEntity.SequenceEqual(_matchPlayerEntity)) { return _playerIndex; }
            if (key.MatchEntity.SequenceEqual(_opponentPlayerEntity)) { return (_playerIndex + 1) % 2; }

            return -1;
        }

        public override async Task GetBalance()
        {
            var balance = await _web3.Eth.GetBalance.SendRequestAsync(_account.Address);
            Logger.Log($"Balance in Wei: {balance.Value}");
        }

        public override async Task<bool> Spectate(string matchEntity, CancellationToken ct = default)
        {
            _matchEntity = matchEntity.HexToByteArray();
            _playerIndex = 0;

            // Calculate player entity.
            _matchPlayerEntity = BitConverter.GetBytes(1);
            Array.Reverse(_matchPlayerEntity);
            _matchPlayerEntity = _matchPlayerEntity.PadTo32Bytes();

            // Calculate oponent player entity.
            _opponentPlayerEntity = BitConverter.GetBytes(2);
            Array.Reverse(_opponentPlayerEntity);
            _opponentPlayerEntity = _opponentPlayerEntity.PadTo32Bytes();

            MatchStatusTableRecord.MatchStatusKey matchStatusKey = new MatchStatusTableRecord.MatchStatusKey();
            matchStatusKey.MatchEntity = _matchEntity;

            MatchStatusTableRecord? matchStatusTableRecord = await SafeContractCall<MatchStatusTableRecord>(() =>
                _tables.MatchStatusTableService.GetTableRecordAsync(matchStatusKey),
                "MatchStatusTableRecord.GetTableRecordAsync");

            using (new Profiler("Querying client pieces"))
            {
                InventoryTableRecord.InventoryKey inventoryKey = new InventoryTableRecord.InventoryKey();
                inventoryKey.MatchEntity = _matchEntity;
                inventoryKey.PlayerEntity = _matchPlayerEntity;

                InventoryTableRecord? inventoryRecord = await SafeContractCall<InventoryTableRecord>(() =>
                        _tables.InventoryTableService.GetTableRecordAsync(inventoryKey),
                        "InventoryTableService.GetTableRecordAsync");
                Debug.Assert(inventoryRecord != null);

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

                InventoryTableRecord? inventoryRecord = await SafeContractCall<InventoryTableRecord>(() =>
                        _tables.InventoryTableService.GetTableRecordAsync(inventoryKey),
                        "InventoryTableService.GetTableRecordAsync");
                Debug.Assert(inventoryRecord != null);

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

            using (new Profiler("Querying positions"))
            {
                foreach (CTCommon.Piece piece in playersPieces[_playerIndex])
                {
                    PositionTableRecord.PositionKey positionKey = new PositionTableRecord.PositionKey();
                    positionKey.MatchEntity = _matchEntity;
                    positionKey.Entity = piece.entity;

                    PositionTableRecord? positionRecord = await SafeContractCall<PositionTableRecord>(() =>
                            _tables.PositionTableService.GetTableRecordAsync(positionKey),
                            "PositionTableService.GetTableRecordAsync");

                    Debug.Assert(positionRecord != null);

                    GetCellAtPosition(positionRecord.Values.X, positionRecord.Values.Y).piece = piece;
                }

                foreach (CTCommon.Piece piece in playersPieces[(_playerIndex + 1) % 2])
                {
                    PositionTableRecord.PositionKey positionKey = new PositionTableRecord.PositionKey();
                    positionKey.MatchEntity = _matchEntity;
                    positionKey.Entity = piece.entity;

                    PositionTableRecord? positionRecord = await SafeContractCall<PositionTableRecord>(() =>
                            _tables.PositionTableService.GetTableRecordAsync(positionKey),
                            "PositionTableService.GetTableRecordAsync");

                    Debug.Assert(positionRecord != null);

                    GetCellAtPosition(positionRecord.Values.X, positionRecord.Values.Y).piece = piece;
                }
            }


            return matchStatusTableRecord != null;
        }

        /*@brief Attempts find returns when accepted. */
        public override async Task FindMatch(CancellationToken ct = default)
        {
            try
            {
                Logger.Log("Joining queue!");
                TransactionReceipt? tr = await SafeContractCall<TransactionReceipt>(() =>
                _systems.MatchSystemService.JoinQueueRequestAndWaitForReceiptAsync(kBoardEntity.ToBytes32(), kGameModeEntity.ToBytes32()),
                "MatchSystemService.JoinQueueRequestAndWaitForReceiptAsync");
            }
            catch (SmartContractCustomErrorRevertException e)
            {
                var fullError = _tctsNamespace.FindCustomErrorException(e);
                if (fullError.ErrorABI.Name == "PlayerAlreadyInQueue")
                {
                    Logger.Log("Player already in queue!");
                }
                else
                {
                    Logger.Log(fullError.ErrorABI.Name);
                }
            }
            catch (Exception ex)
            {
                Logger.Log($"{ex.Message}!");
            }

            // Wait until matched.
            while ((!ct.IsCancellationRequested))
            {
                Console.Clear();

                PlayerStatusTableRecord.PlayerStatusKey playerStatusKey = new PlayerStatusTableRecord.PlayerStatusKey();
                playerStatusKey.PlayerEntity = _addressAsBytes.PadTo32Bytes();

                PlayerStatusTableRecord? playerStatusTableRecord = await SafeContractCall<PlayerStatusTableRecord>(() =>
                    _tables.PlayerStatusTableService.GetTableRecordAsync(playerStatusKey),
                    "PlayerStatusTableService.GetTableRecordAsync");
                Debug.Assert(playerStatusTableRecord != null);

                if (playerStatusTableRecord.Values.Status == (byte)PlayerStatusTypes.Queueing) { Logger.Log("Searching for match.."); }

                if (playerStatusTableRecord.Values.Status == (byte)PlayerStatusTypes.Playing)
                {
                    // Calculate player entity.
                    _matchEntity = playerStatusTableRecord.Values.MatchEntity;
                    _matchPlayerEntity = playerStatusTableRecord.Values.MatchPlayerEntity;
                    byte[] mpeBigEndian = new byte[32];
                    Array.Copy(_matchPlayerEntity, mpeBigEndian, 32);
                    Array.Reverse(mpeBigEndian);

                    // Calculate oponent player entity.
                    _opponentPlayerEntity = BitConverter.GetBytes(((BitConverter.ToUInt32(mpeBigEndian)) % 2) + 1);
                    Array.Reverse(_opponentPlayerEntity);
                    _opponentPlayerEntity = _opponentPlayerEntity.PadTo32Bytes();

                    Logger.Log($"Match found or already exists: {_matchEntity.ToHex()}");
                    Logger.Log($"You are player: {_matchPlayerEntity.ToHex()}");

                    // Get temp player index
                    _playerIndex = BitConverter.ToInt32(mpeBigEndian) - 1;

                    return;
                }

                await Task.Delay(kPollingTime, ct);
            }
        }

        public override async Task AcceptMatch(CancellationToken ct = default)
        {
            try
            {
                TransactionReceipt receipt = await _systems.MatchSystemService.SetPlayerReadyAndStartRequestAndWaitForReceiptAsync(_matchEntity);
                if (receipt.Failed()) { Logger.Log("Failed to accept match!"); }
                Logger.Log("Accepting match...");
            }
            catch (SmartContractCustomErrorRevertException ex)
            {
                Logger.Log("Transaction Exception On SetPlayerReadyAndStartRequestAndWaitForReceiptAsync: " + ex.Message);
                var fullError = _tctsNamespace.FindCustomErrorException(ex);
                Logger.Log(fullError.ErrorABI.Name);
            }
            catch (Exception ex)
            {
                Logger.Log("Transaction Exception On SetPlayerReadyAndStartRequestAndWaitForReceiptAsync: " + ex.Message);
            }

            // Check if both players have accepted.
            while (!ct.IsCancellationRequested)
            {
                Logger.Log("Waiting for other player to accept match..");

                MatchStatusTableRecord.MatchStatusKey matchStatusKey = new MatchStatusTableRecord.MatchStatusKey();
                matchStatusKey.MatchEntity = _matchEntity;
                MatchStatusTableRecord matchStatusTableRecord = await _tables.MatchStatusTableService.GetTableRecordAsync(matchStatusKey);

                MatchStatusTypes matchStatus = (MatchStatusTypes)matchStatusTableRecord.Values.Value;
                if (matchStatus == MatchStatusTypes.Active)
                {
                    Logger.Log($"All players accepted {_matchEntity.ToHex()}!");
                    break;
                }

                if (matchStatus == MatchStatusTypes.Cancelled)
                {
                    Logger.Log($"Match {_matchEntity.ToHex()} cancelled!");
                    break;
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

                SpawnStatusTableRecord? record = await SafeContractCall<SpawnStatusTableRecord>(() =>
                    _tables.SpawnStatusTableService.GetTableRecordAsync(key),
                    "SpawnStatusTableService.GetTableRecordAsync");
                Debug.Assert(record != null);

                if ((SpawnStatusTypes)record.Values.Value != SpawnStatusTypes.None)
                {
                    return false;
                }

                var encoder = new ABIEncode();
                var encodedData = encoder.GetABIEncoded(new ABIValue("uint256[]", selectedUnits), new ABIValue("bytes32", secret));
                var sha3 = new Sha3Keccack();
                byte[] unitsHash = sha3.CalculateHash(encodedData);

                TransactionReceipt? receipt = await SafeContractCall<TransactionReceipt>(() =>
                        _systems.BuySystemService.CommitBuyRequestAndWaitForReceiptAsync(unitsHash, _matchEntity),
                        "BuySystemService.CommitBuyRequestAndWaitForReceiptAsync");

                if (receipt != null && !receipt.Failed())
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

                SpawnStatusTableRecord? record = await SafeContractCall<SpawnStatusTableRecord>(() =>
                    _tables.SpawnStatusTableService.GetTableRecordAsync(key),
                    "SpawnStatusTableService.GetTableRecordAsync");
                Debug.Assert(record != null);

                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.RevealBuying)
                {
                    TransactionReceipt? receipt = await SafeContractCall<TransactionReceipt>(() =>
                            _systems.BuySystemService.RevealBuyRequestAndWaitForReceiptAsync(_matchEntity, selectedUnits, secret),
                            "BuySystemService.RevealBuyRequestAndWaitForReceiptAsync");

                    Debug.Assert(receipt != null);
                }

                if ((SpawnStatusTypes)record.Values.Value >= SpawnStatusTypes.CommitSpawning)
                {
                    using (new Profiler("Querying client pieces"))
                    {
                        InventoryTableRecord.InventoryKey inventoryKey = new InventoryTableRecord.InventoryKey();
                        inventoryKey.MatchEntity = _matchEntity;
                        inventoryKey.PlayerEntity = _matchPlayerEntity;

                        InventoryTableRecord? inventoryRecord = await SafeContractCall<InventoryTableRecord>(() =>
                                _tables.InventoryTableService.GetTableRecordAsync(inventoryKey),
                                "InventoryTableService.GetTableRecordAsync");
                        Debug.Assert(inventoryRecord != null);

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

                        InventoryTableRecord? inventoryRecord = await SafeContractCall<InventoryTableRecord>(() =>
                                _tables.InventoryTableService.GetTableRecordAsync(inventoryKey),
                                "InventoryTableService.GetTableRecordAsync");
                        Debug.Assert(inventoryRecord != null);

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

            List<PositionData> positions = new List<PositionData>();
            for (int i = 0; i < playerPositions.Count; i++) { positions.Add(playerPositions[i].AsPlayer(_playerIndex)); }

            bool isComplete = false;
            while (!isComplete)
            {
                if (ct.IsCancellationRequested)
                {
                    throw new TaskCanceledException();
                }

                SpawnStatusTableRecord.SpawnStatusKey key = new SpawnStatusTableRecord.SpawnStatusKey();
                key.MatchEntity = _matchEntity;
                key.PlayerEntity = _matchPlayerEntity;

                SpawnStatusTableRecord? record = await SafeContractCall<SpawnStatusTableRecord>(() =>
                    _tables.SpawnStatusTableService.GetTableRecordAsync(key),
                    "SpawnStatusTableService.GetTableRecordAsync");
                Debug.Assert(record != null);

                // Fail if already beyond phase.
                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.CommitSpawning)
                {
                    // Select spawn positions.
                    {
                        List<byte[]> entities = new();
                        foreach (CTCommon.Piece piece in playersPieces[_playerIndex]) { entities.Add(piece.entity); }

                        byte[]? spawnHash = await SafeContractCall<byte[]>(() =>
                                _systems.ViewSystemService.GenerateSpawnCommitHashQueryAsync(positions, entities, secret),
                                "ViewSystemService.GenerateSpawnCommitHashQueryAsync");
                        Debug.Assert(spawnHash != null, "Invalid spawn positions!");

                        TransactionReceipt? commitSpawnReceipt = await SafeContractCall<TransactionReceipt>(() =>
                                _systems.SpawnSystemService.CommitSpawnRequestAndWaitForReceiptAsync(spawnHash, _matchEntity),
                                "SpawnSystemService.CommitSpawnRequestAndWaitForReceiptAsync");
                        Debug.Assert(commitSpawnReceipt != null);
                    }
                }

                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.RevealSpawning)
                {
                    foreach (var position in positions) { Logger.Log($"{position.X},{position.Y}"); }

                    List<byte[]> entities = new();
                    foreach (CTCommon.Piece piece in playersPieces[_playerIndex]) { entities.Add(piece.entity); }

                    TransactionReceipt? revealSpawnReceipt = await SafeContractCall<TransactionReceipt>(() =>
                            _systems.SpawnSystemService.RevealSpawnRequestAndWaitForReceiptAsync(_matchEntity, positions, entities, secret),
                            "SpawnSystemService.RevealSpawnRequestAndWaitForReceiptAsync");

                    Debug.Assert(revealSpawnReceipt != null);
                }

                if ((SpawnStatusTypes)record.Values.Value == SpawnStatusTypes.Ready)
                {
                    // Get player index.
                    MatchPlayersTableRecord.MatchPlayersKey matchPlayersKey = new MatchPlayersTableRecord.MatchPlayersKey();
                    matchPlayersKey.MatchEntity = _matchEntity;

                    MatchPlayersTableRecord? matchPlayersRecord = await SafeContractCall<MatchPlayersTableRecord>(() =>
                            _tables.MatchPlayersTableService.GetTableRecordAsync(matchPlayersKey),
                            "MatchPlayersTableService.GetTableRecordAsync");

                    Debug.Assert(matchPlayersRecord != null);
                    Debug.Assert(matchPlayersRecord.Values.Value.Count > 0);

                    _playerIndex = matchPlayersRecord.Values.Value[0].SequenceEqual(_matchPlayerEntity) ? 0 : 1;

                    using (new Profiler("Querying positions"))
                    {
                        foreach (CTCommon.Piece piece in playersPieces[_playerIndex])
                        {
                            PositionTableRecord.PositionKey positionKey = new PositionTableRecord.PositionKey();
                            positionKey.MatchEntity = _matchEntity;
                            positionKey.Entity = piece.entity;

                            PositionTableRecord? positionRecord = await SafeContractCall<PositionTableRecord>(() =>
                                    _tables.PositionTableService.GetTableRecordAsync(positionKey),
                                    "PositionTableService.GetTableRecordAsync");

                            Debug.Assert(positionRecord != null);

                            GetCellAtPosition(positionRecord.Values.X, positionRecord.Values.Y).piece = piece;
                        }

                        foreach (CTCommon.Piece piece in playersPieces[(_playerIndex + 1) % 2])
                        {
                            PositionTableRecord.PositionKey positionKey = new PositionTableRecord.PositionKey();
                            positionKey.MatchEntity = _matchEntity;
                            positionKey.Entity = piece.entity;

                            PositionTableRecord? positionRecord = await SafeContractCall<PositionTableRecord>(() =>
                                    _tables.PositionTableService.GetTableRecordAsync(positionKey),
                                    "PositionTableService.GetTableRecordAsync");

                            Debug.Assert(positionRecord != null);

                            GetCellAtPosition(positionRecord.Values.X, positionRecord.Values.Y).piece = piece;
                        }
                    }

                    isComplete = true;
                }

                await Task.Delay(kPollingTime, ct);
            }
        }

        public override async Task<bool> Move(CTCommon.Piece piece, List<PositionData> path)
        {
            TransactionReceipt? receipt = await SafeContractCall<TransactionReceipt>(() =>
                    _systems.MoveSystemService.MoveRequestAndWaitForReceiptAsync(_matchEntity, piece.entity, path),
                    "MoveSystemService.MoveRequestAndWaitForReceiptAsync");

            return receipt != null;
        }

        public override async Task<bool> Attack(CTCommon.Piece piece, CTCommon.Piece target)
        {
            TransactionReceipt? receipt = await SafeContractCall<TransactionReceipt>(() =>
                    _systems.CombatSystemService.AttackRequestAndWaitForReceiptAsync(_matchEntity, piece.entity, target.entity),
                    "CombatSystemService.AttackRequestAndWaitForReceiptAsync");

            return receipt != null;
        }

        public override async Task EndTurn()
        {
            TransactionReceipt? receipt = await SafeContractCall<TransactionReceipt>(() =>
                    _systems.TurnSystemService.EndTurnRequestAndWaitForReceiptAsync(_matchEntity),
                    "TurnSystemService.EndTurnRequestAndWaitForReceiptAsync");
        }

        public override async Task<bool> Leave(CancellationToken ct = default)
        {
            TransactionReceipt? receiept = await SafeContractCall<TransactionReceipt>(() =>
                    _systems.MatchSystemService.LeaveRequestAndWaitForReceiptAsync(),
                    "MatchSystemService.LeaveRequestAndWaitForReceiptAsync");

            return true;
        }

        public override async Task SyncBoard()
        {
            // Query player turn
            using (new Profiler("Querying player turn data."))
            {
                ActivePlayerTableRecord.ActivePlayerKey matchPlayersKey = new ActivePlayerTableRecord.ActivePlayerKey();
                matchPlayersKey.MatchEntity = _matchEntity;

                ActivePlayerTableRecord? activePlayerRecord = await SafeContractCall<ActivePlayerTableRecord>(() =>
                {
                    return _tables.ActivePlayerTableService.GetTableRecordAsync(matchPlayersKey);
                });

                if (activePlayerRecord == null || activePlayerRecord.Values == null)
                {
                    Logger.Log("Error: Failed to retrieve ActivePlayer record or its Values. Cannot sync board!", Logger.LogLevel.Error);
                    return;
                }

                if (_currentPlayerIndex != (int)activePlayerRecord.Values.PlayerIndex)
                {
                    RaiseEndTurn(_currentPlayerIndex);
                    _currentPlayerIndex = (int)activePlayerRecord.Values.PlayerIndex;
                }
            }

            // Check attack
            LastAttackCommitedTableRecord.LastAttackCommitedKey lastAttackCommitedKey = new LastAttackCommitedTableRecord.LastAttackCommitedKey();
            lastAttackCommitedKey.MatchEntity = _matchEntity;

            LastAttackCommitedTableRecord? lastAttackCommitedRecord = await SafeContractCall<LastAttackCommitedTableRecord>(() =>
                    _tables.LastAttackCommitedTableService.GetTableRecordAsync(lastAttackCommitedKey),
                    "LastAttackCommitedTableService.GetTableRecordAsync");

            if (lastAttackCommitedRecord != null)
            {
                // TODO: Check timestamp
                if (lastAttackCommitedRecord.Values.Timestamp > _lastMoveTimeStamp)
                {
                    CTCommon.Piece? attacker = null;
                    CTCommon.Piece? target = null;
                    foreach (CTCommon.Piece searchPiece in playersPieces[_playerIndex])
                    {
                        if (searchPiece.entity.SequenceEqual(lastAttackCommitedRecord.AttackerPieceEntity))
                        {
                            attacker = searchPiece;
                            break;
                        }

                        if (searchPiece.entity.SequenceEqual(lastAttackCommitedRecord.AttackerPieceEntity))
                        {
                            target = searchPiece;
                            break;
                        }

                    }

                    foreach (CTCommon.Piece searchPiece in playersPieces[(_playerIndex + 1) % 2])
                    {
                        if (searchPiece.entity.SequenceEqual(lastAttackCommitedRecord.AttackerPieceEntity))
                        {
                            attacker = searchPiece;
                            break;
                        }

                        if (searchPiece.entity.SequenceEqual(lastAttackCommitedRecord.AttackerPieceEntity))
                        {
                            target = searchPiece;
                            break;
                        }
                    }

                    if (attacker != null && target != null)
                    {
                        RaiseAttack(attacker, target);
                        _lastMoveTimeStamp = lastAttackCommitedRecord.Values.Timestamp;
                    }
                }
            }

            // Update board positions
            using (new Profiler("Querying piece data."))
            {
                for (uint y = 1; y < kBoardH + 1; y++)
                {
                    for (uint x = 1; x < kBoardW + 1; x++)
                    {
                        (uint X, uint Y) curPos = new(x, y);
                        Cell prevCell = GetCellAtPosition(curPos.X, curPos.Y);

                        if (prevCell.piece == null) continue;

                        // Check position.
                        PositionTableRecord.PositionKey positionKey = new PositionTableRecord.PositionKey();
                        positionKey.MatchEntity = _matchEntity;
                        positionKey.Entity = prevCell.piece.entity;

                        PositionTableRecord? positionRecord = await SafeContractCall<PositionTableRecord>(() =>
                                _tables.PositionTableService.GetTableRecordAsync(positionKey),
                                "PositionTableService.GetTableRecordAsync");

                        if (positionRecord == null || positionRecord.Values == null)
                        {
                            Logger.Log(
                                $"Error: PositionTableService returned null or missing Values " +
                                $"for entity {BitConverter.ToString(prevCell.piece.entity)}",
                                Logger.LogLevel.Error
                            );

                            return;
                        }

                        if (positionRecord.Values.X != 0 || (positionRecord.Values.Y != 0))
                        {
                            if (curPos.X != positionRecord.Values.X || curPos.Y != positionRecord.Values.Y)
                            {
                                List<PositionData> path = new List<PositionData>();
                                path.Add(new PositionData { X = positionRecord.Values.X, Y = positionRecord.Values.Y });

                                RaiseMove(prevCell.piece, path);

                                GetCellAtPosition(positionRecord.Values.X, positionRecord.Values.Y).piece = prevCell.piece;
                                prevCell.piece = null;
                            }
                        }
                        else
                        {
                            Logger.Log(
                                $"Invlaid position entry {BitConverter.ToString(prevCell.piece.entity)}. given {_matchEntity.ToHex()}",
                                Logger.LogLevel.Error
                            );
                        }
                    }
                }
            }
        }

        public override async Task<MatchStatusTypes> GetMatchStatus()
        {
            MatchStatusTableRecord.MatchStatusKey matchStatusKey = new MatchStatusTableRecord.MatchStatusKey();
            matchStatusKey.MatchEntity = _matchEntity;
            MatchStatusTableRecord matchStatusTableRecord = await _tables.MatchStatusTableService.GetTableRecordAsync(matchStatusKey);

            return (MatchStatusTypes)matchStatusTableRecord.Values.Value;
        }

        private async Task<T?> SafeContractCall<T>(Func<Task<T>> contractCall, string errorMessagePrefix = "")
        {
            Debug.Assert(_tctsNamespace != null, $"Transaction Exception::{errorMessagePrefix}: tctsNamespace is null!");

            try
            {
                return await contractCall();
            }
            catch (SmartContractCustomErrorRevertException ex)
            {
                Logger.Log($"Transaction Exception::{errorMessagePrefix}: {ex.Message}");
                var fullError = _tctsNamespace.FindCustomErrorException(ex);
                Logger.Log(fullError.ErrorABI.Name);

                return default;
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message);
                return default;
            }
        }
    }
}
