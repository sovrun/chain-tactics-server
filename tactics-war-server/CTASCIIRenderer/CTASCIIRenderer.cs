namespace CTASCII;

using CTHeadless;

public static class CTASCIIRenderer
{
    public static readonly List<char> kLegend = new List<char>
    {
        '?',  // Unknown piece
        '#',  // Fortress
        'S',  // FootSoldier
        'L',  // Lancer
        'P',  // Priest
        'A',  // Archer
        'F',  // FireMage
        'I',  // IceMage

        '0'   // Empty
    };

    public const int inverseRefreshRate = 500;

    public const string Reset = "\u001b[0m";
    public const string Red = "\u001b[31m";
    public const string Blue = "\u001b[34m";
    public const string Yellow = "\u001b[33;1m";

    public static void Begin()
    {
        Console.Clear();
    }

    // @brief Renders the board in standard output given a context
    public static void Frame(CTContext ctContext, (uint x, uint y) cursorPos)
    {
        // ~ Top border. ~
        for (int i = 0; i < CTContext.kBoardW / 2; i++) Console.Write("---");
        Console.WriteLine(ctContext.GetMatchEntity());
        for (int i = CTContext.kBoardW / 2; i < CTContext.kBoardW; i++) Console.Write("---");
        Console.WriteLine(); Console.WriteLine();

        lock (ctContext.BoardLock)
        {
            for (int y = 0; y < CTContext.kBoardH; y++)
            {
                Console.Write("|");
                for (int x = 0; x < CTContext.kBoardW; x++)
                {
                    CTCommon.Cell cell = ctContext.Board[y * CTContext.kBoardW + x];
                    if (cell.piece != null)
                    {
                        if (cursorPos.y == y + 1 && cursorPos.x == x + 1)
                        {
                            Console.Write(Yellow);
                        }
                        else
                        {
                            if (cell.piece.owner == ctContext.GetPlayerIndex())
                            {
                                Console.Write(Blue);
                            }
                            else
                            {
                                Console.Write(Red);
                            }
                        }

                        Console.Write(kLegend[(int)cell.piece.type]);
                        Console.Write(Reset);
                    }
                    else
                    {
                        if (cursorPos.y == y + 1 && cursorPos.x == x + 1)
                        {
                            Console.Write(Yellow);
                        }
                        Console.Write(kLegend[kLegend.Count - 1]);
                        Console.Write(Reset);
                    }

                    Console.Write("|");
                }

                Console.WriteLine();
            }
        }

        // ~ Bottom border. ~
        Console.WriteLine();
        for (int i = 0; i < CTContext.kBoardW; i++) Console.Write("---");
        Console.WriteLine();
    }
}
