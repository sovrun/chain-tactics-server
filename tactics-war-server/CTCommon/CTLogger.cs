namespace CTCommon
{
    public class Logger
    {
        public enum LogLevel
        {
            Trace,
            Info,
            Debug,
            Error
        }

        public static Action<string, LogLevel> LogFn { get; set; } = DefaultLogger;

        private static void DefaultLogger(string message, LogLevel logLevel)
        {
            Console.WriteLine(message);
        }

        public static void Log(string message, LogLevel logLevel = LogLevel.Trace)
        {
            LogFn(message, logLevel);
        }
    };
}
