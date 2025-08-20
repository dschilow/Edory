using Microsoft.AspNetCore.Mvc;
using Edory.Memory.Domain;
using Edory.Memory.Domain.Repositories;

namespace Edory.Api.Controllers;

/// <summary>
/// API Controller für Charakter-Gedächtnis Management
/// Verwaltet das hierarchische Gedächtnissystem
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class MemoryController : ControllerBase
{
    private readonly ICharacterMemoryRepository _memoryRepository;
    private readonly ILogger<MemoryController> _logger;

    public MemoryController(
        ICharacterMemoryRepository memoryRepository,
        ILogger<MemoryController> logger)
    {
        _memoryRepository = memoryRepository;
        _logger = logger;
    }

    /// <summary>
    /// Holt alle Gedächtnisse einer CharacterInstance
    /// </summary>
    [HttpGet("character-instance/{characterInstanceId}")]
    public async Task<ActionResult<IEnumerable<CharacterMemoryDto>>> GetByCharacterInstance(
        Guid characterInstanceId,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var memories = await _memoryRepository.GetByCharacterInstanceIdAsync(characterInstanceId, cancellationToken);
            var dtos = memories.Select(m => MapToDto(m));
            
            _logger.LogInformation("Gefunden {Count} Gedächtnisse für CharacterInstance {CharacterInstanceId}", 
                memories.Count(), characterInstanceId);
            
            return Ok(dtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler beim Laden der Gedächtnisse für CharacterInstance {CharacterInstanceId}", 
                characterInstanceId);
            return StatusCode(500, "Fehler beim Laden der Gedächtnisse");
        }
    }

    /// <summary>
    /// Erstellt oder holt alle Gedächtnistypen für eine CharacterInstance
    /// </summary>
    [HttpPost("character-instance/{characterInstanceId}/initialize")]
    public async Task<ActionResult<IEnumerable<CharacterMemoryDto>>> InitializeMemories(
        Guid characterInstanceId,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var memories = await _memoryRepository.GetOrCreateAllMemoryTypesAsync(characterInstanceId, cancellationToken);
            var dtos = memories.Select(m => MapToDto(m));
            
            _logger.LogInformation("Initialisiert Gedächtnisse für CharacterInstance {CharacterInstanceId}", 
                characterInstanceId);
            
            return Ok(dtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler bei der Initialisierung der Gedächtnisse für CharacterInstance {CharacterInstanceId}", 
                characterInstanceId);
            return StatusCode(500, "Fehler bei der Gedächtnis-Initialisierung");
        }
    }

    /// <summary>
    /// Fügt ein Memory-Fragment hinzu
    /// </summary>
    [HttpPost("character-instance/{characterInstanceId}/memory/{memoryType}/fragment")]
    public async Task<ActionResult<CharacterMemoryDto>> AddMemoryFragment(
        Guid characterInstanceId,
        MemoryType memoryType,
        [FromBody] AddMemoryFragmentRequest request,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var memory = await _memoryRepository.GetByCharacterInstanceAndTypeAsync(
                characterInstanceId, memoryType, cancellationToken);

            if (memory == null)
            {
                // Erstelle neues Memory falls nicht vorhanden
                memory = CharacterMemory.Create(characterInstanceId, memoryType);
                memory = await _memoryRepository.AddAsync(memory, cancellationToken);
            }

            var emotionalContext = EmotionalContext.Create(
                request.EmotionalContext?.Joy ?? 5,
                request.EmotionalContext?.Sadness ?? 0,
                request.EmotionalContext?.Fear ?? 0,
                request.EmotionalContext?.Anger ?? 0,
                request.EmotionalContext?.Surprise ?? 0,
                request.EmotionalContext?.Pride ?? 0,
                request.EmotionalContext?.Excitement ?? 0,
                request.EmotionalContext?.Calmness ?? 5);

            var fragment = MemoryFragment.Create(
                request.Content,
                request.Tags ?? Array.Empty<string>(),
                memoryType,
                request.Importance,
                emotionalContext);

            memory.AddMemoryFragment(fragment);
            await _memoryRepository.UpdateAsync(memory, cancellationToken);

            _logger.LogInformation("Memory-Fragment hinzugefügt für CharacterInstance {CharacterInstanceId}, Typ {MemoryType}", 
                characterInstanceId, memoryType);

            return Ok(MapToDto(memory));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler beim Hinzufügen des Memory-Fragments für CharacterInstance {CharacterInstanceId}", 
                characterInstanceId);
            return StatusCode(500, "Fehler beim Hinzufügen des Memory-Fragments");
        }
    }

    /// <summary>
    /// Führt Memory-Konsolidierung durch
    /// </summary>
    [HttpPost("character-instance/{characterInstanceId}/consolidate")]
    public async Task<ActionResult<ConsolidationResultDto>> ConsolidateMemories(
        Guid characterInstanceId,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var wasConsolidated = await _memoryRepository.ConsolidateMemoriesAsync(characterInstanceId, cancellationToken);
            
            _logger.LogInformation("Memory-Konsolidierung für CharacterInstance {CharacterInstanceId}: {Result}", 
                characterInstanceId, wasConsolidated ? "Erfolgreich" : "Keine Konsolidierung notwendig");

            return Ok(new ConsolidationResultDto
            {
                WasConsolidated = wasConsolidated,
                Message = wasConsolidated 
                    ? "Erinnerungen erfolgreich konsolidiert" 
                    : "Keine Konsolidierung notwendig"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler bei der Memory-Konsolidierung für CharacterInstance {CharacterInstanceId}", 
                characterInstanceId);
            return StatusCode(500, "Fehler bei der Memory-Konsolidierung");
        }
    }

    /// <summary>
    /// Sucht in Gedächtnissen nach Inhalt
    /// </summary>
    [HttpGet("character-instance/{characterInstanceId}/search")]
    public async Task<ActionResult<IEnumerable<CharacterMemoryDto>>> SearchMemories(
        Guid characterInstanceId,
        [FromQuery] string query,
        [FromQuery] string[]? tags = null,
        [FromQuery] MemoryImportance? minImportance = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var memories = await _memoryRepository.SearchAsync(
                characterInstanceId, query, tags, minImportance, cancellationToken);
            
            var dtos = memories.Select(m => MapToDto(m));
            
            _logger.LogInformation("Gedächtnis-Suche für CharacterInstance {CharacterInstanceId} mit Query '{Query}': {Count} Ergebnisse", 
                characterInstanceId, query, memories.Count());

            return Ok(dtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler bei der Gedächtnis-Suche für CharacterInstance {CharacterInstanceId}", 
                characterInstanceId);
            return StatusCode(500, "Fehler bei der Gedächtnis-Suche");
        }
    }

    /// <summary>
    /// Bereinigt alle alten Gedächtnisse
    /// </summary>
    [HttpPost("cleanup")]
    public async Task<ActionResult<string>> CleanupOldMemories(CancellationToken cancellationToken = default)
    {
        try
        {
            await _memoryRepository.CleanupOldMemoriesAsync(cancellationToken);
            
            _logger.LogInformation("Alte Gedächtnisse erfolgreich bereinigt");
            
            return Ok("Alte Gedächtnisse erfolgreich bereinigt");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler bei der Bereinigung alter Gedächtnisse");
            return StatusCode(500, "Fehler bei der Bereinigung alter Gedächtnisse");
        }
    }

    private static CharacterMemoryDto MapToDto(CharacterMemory memory)
    {
        return new CharacterMemoryDto
        {
            Id = memory.Id.Value,
            CharacterInstanceId = memory.CharacterInstanceId,
            Type = memory.Type,
            CreatedAt = memory.CreatedAt,
            LastUpdatedAt = memory.LastUpdatedAt,
            Fragments = memory.Fragments.Select(f => new MemoryFragmentDto
            {
                Id = f.Id,
                Content = f.Content,
                Tags = f.Tags,
                Importance = f.Importance,
                EmotionalContext = new EmotionalContextDto
                {
                    Joy = f.EmotionalContext.Joy,
                    Sadness = f.EmotionalContext.Sadness,
                    Fear = f.EmotionalContext.Fear,
                    Anger = f.EmotionalContext.Anger,
                    Surprise = f.EmotionalContext.Surprise,
                    Pride = f.EmotionalContext.Pride,
                    Excitement = f.EmotionalContext.Excitement,
                    Calmness = f.EmotionalContext.Calmness
                },
                Timestamp = f.Timestamp,
                Type = f.Type,
                IsActive = f.IsActive
            }).ToList()
        };
    }
}

// DTOs für API
public class CharacterMemoryDto
{
    public Guid Id { get; set; }
    public Guid CharacterInstanceId { get; set; }
    public MemoryType Type { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime LastUpdatedAt { get; set; }
    public List<MemoryFragmentDto> Fragments { get; set; } = new();
}

public class MemoryFragmentDto
{
    public Guid Id { get; set; }
    public string Content { get; set; } = string.Empty;
    public string[] Tags { get; set; } = Array.Empty<string>();
    public MemoryImportance Importance { get; set; }
    public EmotionalContextDto EmotionalContext { get; set; } = new();
    public DateTime Timestamp { get; set; }
    public MemoryType Type { get; set; }
    public bool IsActive { get; set; }
}

public class EmotionalContextDto
{
    public int Joy { get; set; }
    public int Sadness { get; set; }
    public int Fear { get; set; }
    public int Anger { get; set; }
    public int Surprise { get; set; }
    public int Pride { get; set; }
    public int Excitement { get; set; }
    public int Calmness { get; set; }
}

public class AddMemoryFragmentRequest
{
    public string Content { get; set; } = string.Empty;
    public string[]? Tags { get; set; }
    public MemoryImportance Importance { get; set; } = MemoryImportance.Normal;
    public EmotionalContextDto? EmotionalContext { get; set; }
}

public class ConsolidationResultDto
{
    public bool WasConsolidated { get; set; }
    public string Message { get; set; } = string.Empty;
}


