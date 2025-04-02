using CTSequencerHub.Services;

var builder = WebApplication.CreateBuilder(args);

if (args.Length == 0)
{
    throw new ArgumentException("RPC URL is required as the first command-line argument.");
}

string rpcUrl = args[0];

// Add the RPC URL to the configuration system
builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
{
    { "RPCUrl", rpcUrl }
});

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHostedService<ChainSyncBackgroundService>();
builder.Services.AddSignalR();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapHub<CTServer.Hubs.CTHub>("/chainTacticsHub");
app.MapHub<CTServer.Hubs.CTSequencerHub>("/chainTacticsSequencerHub");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
