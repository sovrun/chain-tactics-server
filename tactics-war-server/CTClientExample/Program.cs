using System.Diagnostics;
using System.Numerics;
using CTCommon;
using CTHeadless;
using TacticsWarMud.TypeDefinitions;
using static CTCommon.ContractDefines;

namespace CTASCII
{
    class Program
    {
        // ~ Game common ~
        static readonly BigInteger kBoardEntity = 1;
        static readonly BigInteger kGameModeEntity = 2;

        enum TurnState
        {
            Selecting,
            Moving,
            Attacking,
        };

        // ~ Move command state ~
        static CTCommon.Piece? selectedPiece = null;
        static List<PositionData> path = new List<PositionData>();

        static bool isRunning = true;
        static bool didWin = false;
        static TurnState turnState = TurnState.Selecting;

        static (uint x, uint y) cursorPos = ((uint)CTContext.kBoardH / 2, (uint)CTContext.kBoardH / 2);

        static void DrawMenu(CTContext ctContext)
        {
            for (int i = 0; i < CTContext.kBoardW / 2; i++) Console.Write("---");
            for (int i = CTContext.kBoardW; i < CTContext.kBoardW; i++) Console.Write("---");
            Console.WriteLine(); Console.WriteLine();

            Console.WriteLine($"Play {ctContext.GetPlayerIndex()} | Current Player {ctContext.GetCurrentPlayerIndex()}");
            if (ctContext.GetPlayerIndex() == ctContext.GetCurrentPlayerIndex())
            {
                switch (turnState)
                {
                    case (TurnState.Selecting):
                        if (selectedPiece != null)
                        {
                            Console.WriteLine($"- Choose action for {CTASCIIRenderer.kLegend[(int)selectedPiece.type]}: Move <[Mm]> or Attack <[Aa]>");
                        }
                        else
                        {
                            Console.WriteLine("- Select piece with <Arrow Keys>)");
                        }
                        break;

                    case (TurnState.Moving):
                        Debug.Assert(selectedPiece != null);
                        Console.WriteLine($"- Move ({CTASCIIRenderer.kLegend[(int)selectedPiece.type]}) with <Arrow Keys> and <Enter> to confirm.");
                        foreach (PositionData data in path) { Console.Write($"({data.X}, {data.Y}) "); }
                        Console.WriteLine();
                        break;

                    case (TurnState.Attacking):
                        Debug.Assert(selectedPiece != null);
                        Console.WriteLine($"- Select for : ({CTASCIIRenderer.kLegend[(int)selectedPiece.type]})");

                        CTCommon.Cell targetCell = ctContext.GetCellAtPosition(cursorPos.x, cursorPos.y);

                        if (targetCell.piece != null)
                        {
                            Console.WriteLine($"Press enter to confirm target:");
                            Console.Write(CTASCIIRenderer.Red);
                            Console.Write(CTASCIIRenderer.kLegend[(int)targetCell.piece.type]);
                            Console.WriteLine(CTASCIIRenderer.Reset);
                        }
                        break;
                }

                Console.WriteLine($"- End turn with <[Ee]> ");
            }
            Console.WriteLine($"- Leave match <[Qq]> ");

            Console.WriteLine();
            for (int i = 0; i < CTContext.kBoardW; i++) Console.Write("---");
            Console.WriteLine();
        }

        static async Task DrawBoardAsync(CTContext ctContext, CancellationToken ct = default)
        {
            while (!ct.IsCancellationRequested)
            {
                // Poll for board state
                await ctContext.SyncBoard();

                // ASCII Renderer
                using (Profiler p = new Profiler("Frame Draw"))
                {
                    CTASCIIRenderer.Begin();
                    CTASCIIRenderer.Frame(ctContext, cursorPos);
                    DrawMenu(ctContext);
                    await Task.Delay(500);
                }
            }
        }

        static async Task Main(string[] args)
        {
            Debug.Assert(args.Length > 2, "Must provide <rpc_url> <private_key> <world_address> and optionally <sequencer_url> as command line arguments!");

            string rpcUrl = args[0];
            string privateKey = args[1];
            string worldAddress = args[2];
            string sequencerUrl = "";

            bool spectator = false;
            string spectatingMatch = "";
            if (args.Length > 3) { sequencerUrl = args[3]; }
            if (args.Length > 4)
            {
                spectatingMatch = args[4];
                spectator = spectatingMatch.Length > 0;
            }

            CTContext ctContext = new CTRawContext(rpcUrl, privateKey, worldAddress);

            ctContext.OnEndTurn += (int playerIdx) =>
            {
                Console.WriteLine($"Player {playerIdx} ended turn");
                /*Environment.Exit(0);*/
            };

            ctContext.OnMove += (CTCommon.Piece piece, List<PositionData> path) =>
            {
                Console.WriteLine($"Piece {piece.type} moved to {path[^1].X}, {path[^1].Y}");
                Environment.Exit(0);
            };

            ctContext.OnAttack += (CTCommon.Piece attacker, CTCommon.Piece target) =>
            {
                Console.WriteLine($"Piece {attacker.type} attacked {target.type}");
                Environment.Exit(0);
            };

            await ctContext.GetBalance();

            if (!spectator)
            {
                // Store player index after finding match
                await ctContext.FindMatch();

                // Accept or decline match
                Console.WriteLine("Press Enter to Accept match or Escape to exit.");
                if (Console.ReadKey(intercept: true).Key == ConsoleKey.Escape)
                {
                    await ctContext.Leave();
                    return;
                }

                await ctContext.AcceptMatch();

                // Choose pieces
                byte[] secret = new byte[] { 1, 2, 3 };
                List<BigInteger> selectedUnits = new List<BigInteger>() { (int)PieceType.Priest, (int)PieceType.Archer };
                List<PositionData> spawnPositions = new();
                spawnPositions.Add(new PositionData { X = 4, Y = 2 });
                spawnPositions.Add(new PositionData { X = 5, Y = 2 });
                spawnPositions.Add(new PositionData { X = 6, Y = 2 });

                if (!await ctContext.SelectUnits(selectedUnits, secret))
                {
                    Console.WriteLine("Failed to select units.");
                    return;
                }

                if (!await ctContext.RevealUnits(selectedUnits, secret))
                {
                    Console.WriteLine("Failed to reveal units.");
                    await ctContext.Leave();
                    return;
                }

                List<CTCommon.Piece> playerPieces = ctContext.PlayerPieces[ctContext.GetPlayerIndex()];
                List<CTCommon.Piece> opponentPieces = ctContext.PlayerPieces[(ctContext.GetPlayerIndex() + 1) % 2];
                Console.WriteLine($"Your piece count: {playerPieces.Count}");
                Console.WriteLine($"Opponent piece count: {opponentPieces.Count}");

                await ctContext.SpawnUnits(selectedUnits, spawnPositions, secret);
            }
            else
            {
                if (!await ctContext.Spectate(spectatingMatch))
                {
                    return;
                }

                Console.WriteLine($"Your are spectating count: {spectatingMatch}");
            }

            CancellationTokenSource renderCTS = new CancellationTokenSource();
            Task renderTask = DrawBoardAsync(ctContext, renderCTS.Token);

            while (isRunning)
            {
                // Check if match is over
                if (MatchStatusTypes.Finished == await ctContext.GetMatchStatus())
                {
                    didWin = await ctContext.FindMatchWinner() == ctContext.GetPlayerIndex();
                    isRunning = false;
                    break;
                }

                if (spectator)
                {
                    await Task.Delay(250);
                    continue;
                }

                if (!Console.KeyAvailable)
                {
                    continue;
                }

                ConsoleKeyInfo keyInfo;
                keyInfo = Console.ReadKey(intercept: true);

                // Update Cursor.
                if (keyInfo.Key == ConsoleKey.UpArrow) { cursorPos.y -= 1; }
                if (keyInfo.Key == ConsoleKey.DownArrow) { cursorPos.y += 1; }
                if (keyInfo.Key == ConsoleKey.RightArrow) { cursorPos.x += 1; }
                if (keyInfo.Key == ConsoleKey.LeftArrow) { cursorPos.x -= 1; }

                // Keep cursor in bounds of board
                Math.Clamp(cursorPos.x, 1, CTContext.kBoardW);
                Math.Clamp(cursorPos.y, 1, CTContext.kBoardH);

                if (keyInfo.Key == ConsoleKey.E)
                {
                    // Clear move cmd state.
                    selectedPiece = null;
                    path.Clear();

                    Console.WriteLine("Ending turn...");
                    await ctContext.EndTurn();
                }

                if (keyInfo.Key == ConsoleKey.Q)
                {
                    Console.WriteLine("Leaving...");
                    await ctContext.Leave();
                }

                if (keyInfo.Key == ConsoleKey.Escape)
                {
                    selectedPiece = null;
                    path.Clear();

                    turnState = TurnState.Selecting;
                }

                switch (turnState)
                {
                    case (TurnState.Selecting):
                        if (selectedPiece != null)
                        {
                            if (keyInfo.Key == ConsoleKey.M) turnState = TurnState.Moving;
                            if (keyInfo.Key == ConsoleKey.A) turnState = TurnState.Attacking;
                        }
                        else
                        {
                            if (keyInfo.Key == ConsoleKey.Enter)
                            {
                                // Clear move cmd state.
                                path.Clear();

                                CTCommon.Cell selectedCell = ctContext.GetCellAtPosition(cursorPos.x, cursorPos.y);
                                if (selectedCell.piece != null && selectedCell.piece.owner == ctContext.GetPlayerIndex())
                                {
                                    selectedPiece = selectedCell.piece;
                                }
                            }
                        }
                        break;

                    case (TurnState.Moving):
                        if (selectedPiece == null) { turnState = TurnState.Selecting; return; }

                        if (keyInfo.Key == ConsoleKey.Enter)
                        {
                            using (Profiler p = new Profiler("Move"))
                            {
                                if (await ctContext.Move(selectedPiece, path))
                                {
                                    turnState = TurnState.Selecting;
                                }
                                else
                                {
                                    Environment.Exit(0);
                                }
                            }
                        }

                        // Prevent repeat positions.
                        if (path.Count > 0)
                        {
                            PositionData lastPosition = path[path.Count - 1];
                            if (lastPosition.X == cursorPos.x && lastPosition.Y == cursorPos.y)
                            {
                                break;
                            }
                        }

                        path.Add(new PositionData { X = cursorPos.x, Y = cursorPos.y });
                        break;

                    case (TurnState.Attacking):
                        if (selectedPiece == null)
                        {
                            turnState = TurnState.Selecting;
                            break;
                        }

                        if (keyInfo.Key == ConsoleKey.Enter)
                        {
                            CTCommon.Piece? targetPiece = ctContext.GetCellAtPosition(cursorPos.x, cursorPos.y).piece;
                            if (targetPiece == null) { turnState = TurnState.Selecting; return; }

                            using (Profiler p = new Profiler("Attack"))
                            {
                                if (await ctContext.Attack(selectedPiece, targetPiece))
                                {
                                    turnState = TurnState.Selecting;
                                }
                            }
                        }
                        break;
                    default:
                        break;
                }
            }

            renderCTS.Cancel();
            await renderTask;

            if (didWin)
            {
                Console.WriteLine("Congratulations you won!");
            }
            else
            {
                Console.WriteLine("Lol! Better luck next time...");
            }
        }
    }
}
