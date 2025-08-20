using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using Edory.Infrastructure.Data;
using Edory.Infrastructure.Repositories;
using Edory.Character.Domain.Repositories;
using Edory.Memory.Domain.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Database Configuration
builder.Services.AddDbContext<EdoryDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Repository Registration
builder.Services.AddScoped<ICharacterRepository, CharacterRepository>();
builder.Services.AddScoped<ICharacterInstanceRepository, CharacterInstanceRepository>();
builder.Services.AddScoped<ICharacterMemoryRepository, CharacterMemoryRepository>();

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Konvertiere Enums zu Strings in JSON
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
        // Verwende CamelCase für JSON-Properties
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
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

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Edory API v1");
        c.RoutePrefix = string.Empty; // Swagger UI als Root-Page
    });
}

app.UseHttpsRedirection();

app.UseCors();

app.UseAuthorization();

app.MapControllers();

// Gesundheitscheck-Endpoint
app.MapGet("/health", () => new { 
    status = "healthy", 
    timestamp = DateTime.UtcNow,
    version = "1.0.0-mvp",
    environment = app.Environment.EnvironmentName 
});

// Root-Endpoint mit API-Informationen
app.MapGet("/", () => new {
    name = "Edory API",
    version = "1.0.0-mvp",
    description = "KI-gestützte Storytelling-Plattform für Kinder und Familien",
    documentation = "/swagger",
    health = "/health",
    endpoints = new
    {
        characters = "/api/characters",
        stories = "/api/stories",
        learning = "/api/learning"
    }
});

app.Run();