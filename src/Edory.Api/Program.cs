using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using Edory.Infrastructure.Data;
using Edory.Infrastructure.Repositories;
using Edory.Character.Domain.Repositories;
// using Edory.Memory.Domain.Repositories; // VORERST DEAKTIVIERT

var builder = WebApplication.CreateBuilder(args);

// Database Configuration
builder.Services.AddDbContext<EdoryDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseNpgsql(connectionString);
    
    // Development: Enable sensitive data logging
    if (builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging();
        options.EnableDetailedErrors();
    }
});

// Repository Registration - MEMORY VORERST DEAKTIVIERT
builder.Services.AddScoped<ICharacterRepository, CharacterRepository>();
builder.Services.AddScoped<ICharacterInstanceRepository, CharacterInstanceRepository>();
// builder.Services.AddScoped<ICharacterMemoryRepository, CharacterMemoryRepository>(); // VORERST DEAKTIVIERT

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Konvertiere Enums zu Strings in JSON
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
        // Verwende CamelCase für JSON-Properties
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        // Ignoriere null values
        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    });

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new()
    {
        Title = "Edory API",
        Version = "v1",
        Description = "Edory - KI-gestützte Storytelling-Plattform für Kinder und Familien",
        Contact = new()
        {
            Name = "Edory Team",
            Email = "support@edory.com"
        }
    });
    
    // Aktiviere XML-Kommentare für bessere API-Dokumentation
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// CORS für Frontend-Entwicklung
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Wende DB-Migrationen automatisch an (Development/Production)
await EnsureDatabaseCreated(app);

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Edory API v1");
        c.RoutePrefix = "swagger";
        c.DocumentTitle = "Edory API Documentation";
    });
}

app.UseHttpsRedirection();
app.UseCors();
app.UseAuthorization();
app.MapControllers();

Console.WriteLine("🚀 Edory API gestartet!");
Console.WriteLine($"🌐 Swagger UI: {(app.Environment.IsDevelopment() ? "https://localhost:5221/swagger" : "N/A")}");
Console.WriteLine($"📡 API Base URL: https://localhost:5221/api");

app.Run();

/// <summary>
/// Stellt sicher, dass die Datenbank erstellt und alle Migrationen angewendet werden
/// </summary>
static async Task EnsureDatabaseCreated(WebApplication app)
{
    try
    {
        using var scope = app.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<EdoryDbContext>();
        
        Console.WriteLine("🔄 Prüfe Datenbank-Status...");
        
        // Prüfe ob die Datenbank existiert
        var canConnect = await context.Database.CanConnectAsync();
        if (!canConnect)
        {
            Console.WriteLine("📊 Erstelle Datenbank...");
            await context.Database.EnsureCreatedAsync();
        }

        // Wende ausstehende Migrationen an
        var pendingMigrations = await context.Database.GetPendingMigrationsAsync();
        if (pendingMigrations.Any())
        {
            Console.WriteLine($"🔧 Wende {pendingMigrations.Count()} Migration(s) an...");
            foreach (var migration in pendingMigrations)
            {
                Console.WriteLine($"   - {migration}");
            }
            await context.Database.MigrateAsync();
            Console.WriteLine("✅ Alle Migrationen erfolgreich angewendet!");
        }
        else
        {
            Console.WriteLine("✅ Datenbank ist aktuell - keine Migrationen erforderlich");
        }

        // Zeige angewendete Migrationen
        var appliedMigrations = await context.Database.GetAppliedMigrationsAsync();
        Console.WriteLine($"📋 Angewendete Migrationen: {appliedMigrations.Count()}");
        
        // Teste Datenbankverbindung
        var testQuery = await context.Characters.CountAsync();
        Console.WriteLine($"🎯 Charaktere in Datenbank: {testQuery}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Fehler beim Datenbanksetup: {ex.Message}");
        Console.WriteLine($"🔍 Details: {ex.InnerException?.Message}");
        
        // In Development: Zeige vollständigen Stack Trace
        if (app.Environment.IsDevelopment())
        {
            Console.WriteLine($"📋 Stack Trace: {ex.StackTrace}");
        }
        
        // Beende die Anwendung nicht, aber logge den Fehler
        Console.WriteLine("⚠️ Anwendung startet trotzdem - Datenbankfunktionen könnten eingeschränkt sein");
    }
}