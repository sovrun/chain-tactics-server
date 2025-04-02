using System.Diagnostics;
using CTCommon;
using CTHeadless;
using TacticsWarMud.TypeDefinitions;

namespace CTASCII;

public static class Menu
{
    enum TurnState
    {
        Selecting,
        Moving,
        Attacking,
    };

    public static (uint x, uint y) CursorPosition = ((uint)CTContext.kBoardH / 2, (uint)CTContext.kBoardH / 2);

    // ~ Move command state ~
    static CTCommon.Piece? selectedPiece = null;
    static List<PositionData> path = new List<PositionData>();

    static TurnState turnState = TurnState.Selecting;

    public static async Task DrawMenu(CTContext ctContext)
    {
        for (int i = 0; i < CTContext.kBoardW / 2; i++) Console.Write("---");
        for (int i = CTContext.kBoardW; i < CTContext.kBoardW; i++) Console.Write("---");
        Console.WriteLine(); Console.WriteLine();

        switch (turnState)
        {
            case (TurnState.Selecting):
                if (selectedPiece != null)
                {
                    Console.WriteLine($"1. Choose action for {CTASCIIRenderer.kLegend[(int)selectedPiece.type]}: Move <[mM]> or Attack <[aA]>");
                }
                else
                {
                    Console.WriteLine("1. Select piece with <Arrow Keys>)");
                }
                break;

            case (TurnState.Moving):
                Debug.Assert(selectedPiece != null);
                Console.WriteLine($"1. Move ({CTASCIIRenderer.kLegend[(int)selectedPiece.type]}) with <Arrow Keys> and <Enter> to confirm.");
                foreach (PositionData data in path) { Console.Write($"({data.X}, {data.Y}) "); }
                Console.WriteLine();
                break;

            case (TurnState.Attacking):
                Debug.Assert(selectedPiece != null);
                Console.WriteLine($"1. Select for : ({CTASCIIRenderer.kLegend[(int)selectedPiece.type]})");

                CTCommon.Cell targetCell = ctContext.GetCellAtPosition(CursorPosition.x, CursorPosition.y);

                if (targetCell.piece != null)
                {
                    Console.WriteLine($"Press enter to confirm target:");
                    Console.Write(CTASCIIRenderer.Red);
                    Console.Write(CTASCIIRenderer.kLegend[(int)targetCell.piece.type]);
                    Console.WriteLine(CTASCIIRenderer.Reset);
                }
                break;
        }

        Console.WriteLine($"2. End turn with <[Ee]> ");
        Console.WriteLine($"3. Leave match <[Qq]> ");

        Console.WriteLine();
        for (int i = 0; i < CTContext.kBoardW; i++) Console.Write("---");
        Console.WriteLine();

        ConsoleKeyInfo keyInfo = Console.ReadKey(intercept: true);

        // Update Cursor.
        if (keyInfo.Key == ConsoleKey.UpArrow) { CursorPosition.y -= 1; }
        if (keyInfo.Key == ConsoleKey.DownArrow) { CursorPosition.y += 1; }
        if (keyInfo.Key == ConsoleKey.RightArrow) { CursorPosition.x += 1; }
        if (keyInfo.Key == ConsoleKey.LeftArrow) { CursorPosition.x -= 1; }

        // Keep cursor in bounds of board
        Math.Clamp(CursorPosition.x, 1, CTContext.kBoardW);
        Math.Clamp(CursorPosition.y, 1, CTContext.kBoardH);

        if (keyInfo.Key == ConsoleKey.E)
        {
            // Clear move cmd state.
            selectedPiece = null;
            path.Clear();

            await ctContext.EndTurn();
        }

        if (keyInfo.Key == ConsoleKey.Q) { await ctContext.Leave(); }

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

                        CTCommon.Cell selectedCell = ctContext.GetCellAtPosition(CursorPosition.x, CursorPosition.y);
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
                    }
                }

                // Prevent repeat positions.
                if (path.Count > 0)
                {
                    PositionData lastPosition = path[path.Count - 1];
                    if (lastPosition.X == CursorPosition.x && lastPosition.Y == CursorPosition.y)
                    {
                        break;
                    }
                }

                path.Add(new PositionData { X = CursorPosition.x, Y = CursorPosition.y });
                break;

            case (TurnState.Attacking):
                if (selectedPiece == null)
                {
                    turnState = TurnState.Selecting;
                    break;
                }

                if (keyInfo.Key == ConsoleKey.Enter)
                {
                    CTCommon.Piece? targetPiece = ctContext.GetCellAtPosition(CursorPosition.x, CursorPosition.y).piece;
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

}
