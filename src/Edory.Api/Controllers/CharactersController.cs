using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Edory.Character.Domain;
using Edory.Character.Domain.Repositories;
using Edory.SharedKernel.ValueObjects;

namespace Edory.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CharactersController : ControllerBase
{
    private readonly ICharacterRepository _characterRepository;
    private readonly ICharacterInstanceRepository _characterInstanceRepository;
    private readonly ILogger<CharactersController> _logger;

    public CharactersController(
        ICharacterRepository characterRepository,
        ICharacterInstanceRepository characterInstanceRepository,
        ILogger<CharactersController> logger)
    {
        _characterRepository = characterRepository;
        _characterInstanceRepository = characterInstanceRepository;
        _logger = logger;
    }
    /// <summary>
    /// Erstellt einen neuen Charakter
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<CharacterResponse>> CreateCharacter([FromBody] CreateCharacterRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            // DNA erstellen
            var characterDna = CharacterDna.Create(
                request.Name,
                request.Description,
                CharacterTraits.Create(
                    request.Courage,
                    request.Creativity,
                    request.Helpfulness,
                    request.Humor,
                    request.Wisdom,
                    request.Curiosity,
                    request.Empathy,
                    request.Persistence),
                request.Appearance,
                request.Personality,
                request.MinAge,
                request.MaxAge);

            // Charakter erstellen
            var character = Edory.Character.Domain.Character.Create(characterDna, FamilyId.From(request.FamilyId));
            
            // Charakter in Datenbank speichern
            await _characterRepository.AddAsync(character, cancellationToken);
            
            // Original-Instanz für die Ersteller-Familie erstellen
            var characterInstance = CharacterInstance.CreateOriginal(character, FamilyId.From(request.FamilyId));
            await _characterInstanceRepository.AddAsync(characterInstance, cancellationToken);
            
            _logger.LogInformation("Neuer Charakter erstellt: {CharacterId} von Familie {FamilyId}", 
                character.Id, request.FamilyId);
            
            var response = new CharacterResponse
            {
                Id = character.Id.Value,
                Name = character.Dna.Name,
                Description = character.Dna.Description,
                Appearance = character.Dna.Appearance,
                Personality = character.Dna.Personality,
                IsPublic = character.IsPublic,
                CreatedAt = character.CreatedAt,
                Traits = new TraitsResponse
                {
                    Courage = character.Dna.BaseTraits.Courage,
                    Creativity = character.Dna.BaseTraits.Creativity,
                    Helpfulness = character.Dna.BaseTraits.Helpfulness,
                    Humor = character.Dna.BaseTraits.Humor,
                    Wisdom = character.Dna.BaseTraits.Wisdom,
                    Curiosity = character.Dna.BaseTraits.Curiosity,
                    Empathy = character.Dna.BaseTraits.Empathy,
                    Persistence = character.Dna.BaseTraits.Persistence
                }
            };
            
            return CreatedAtAction(nameof(GetCharacter), new { id = character.Id.Value }, response);
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning("Ungültige Eingabe beim Erstellen des Charakters: {Error}", ex.Message);
            return BadRequest(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler beim Erstellen des Charakters");
            return StatusCode(500, new { error = "Fehler beim Erstellen des Charakters" });
        }
    }
    
    /// <summary>
    /// Holt einen Charakter nach ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<CharacterResponse>> GetCharacter(Guid id, CancellationToken cancellationToken = default)
    {
        try
        {
            var character = await _characterRepository.GetByIdAsync(CharacterId.From(id), cancellationToken);
            
            if (character == null)
            {
                return NotFound(new { error = "Charakter nicht gefunden" });
            }

            var response = new CharacterResponse
            {
                Id = character.Id.Value,
                Name = character.Dna.Name,
                Description = character.Dna.Description,
                Appearance = character.Dna.Appearance,
                Personality = character.Dna.Personality,
                IsPublic = character.IsPublic,
                CreatedAt = character.CreatedAt,
                Traits = new TraitsResponse
                {
                    Courage = character.Dna.BaseTraits.Courage,
                    Creativity = character.Dna.BaseTraits.Creativity,
                    Helpfulness = character.Dna.BaseTraits.Helpfulness,
                    Humor = character.Dna.BaseTraits.Humor,
                    Wisdom = character.Dna.BaseTraits.Wisdom,
                    Curiosity = character.Dna.BaseTraits.Curiosity,
                    Empathy = character.Dna.BaseTraits.Empathy,
                    Persistence = character.Dna.BaseTraits.Persistence
                }
            };
            
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler beim Laden des Charakters {CharacterId}", id);
            return StatusCode(500, new { error = "Fehler beim Laden des Charakters" });
        }
    }
    
    /// <summary>
    /// Listet alle öffentlichen Charaktere auf
    /// </summary>
    [HttpGet("public")]
    public async Task<ActionResult<List<CharacterResponse>>> GetPublicCharacters(CancellationToken cancellationToken = default)
    {
        try
        {
            var characters = await _characterRepository.GetPublicCharactersAsync(cancellationToken);
            
            var responses = characters.Select(character => new CharacterResponse
            {
                Id = character.Id.Value,
                Name = character.Dna.Name,
                Description = character.Dna.Description,
                Appearance = character.Dna.Appearance,
                Personality = character.Dna.Personality,
                IsPublic = character.IsPublic,
                CreatedAt = character.CreatedAt,
                Traits = new TraitsResponse
                {
                    Courage = character.Dna.BaseTraits.Courage,
                    Creativity = character.Dna.BaseTraits.Creativity,
                    Helpfulness = character.Dna.BaseTraits.Helpfulness,
                    Humor = character.Dna.BaseTraits.Humor,
                    Wisdom = character.Dna.BaseTraits.Wisdom,
                    Curiosity = character.Dna.BaseTraits.Curiosity,
                    Empathy = character.Dna.BaseTraits.Empathy,
                    Persistence = character.Dna.BaseTraits.Persistence
                }
            }).ToList();
            
            _logger.LogInformation("Gefunden {Count} öffentliche Charaktere", responses.Count);
            
            return Ok(responses);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler beim Laden der öffentlichen Charaktere");
            return StatusCode(500, new { error = "Fehler beim Laden der öffentlichen Charaktere" });
        }
    }

    [HttpGet]
    public async Task<ActionResult<List<CharacterResponse>>> GetCharacters([FromQuery] Guid? familyId = null, CancellationToken cancellationToken = default)
    {
        try
        {
            var effectiveFamilyId = familyId ?? Guid.Parse("11111111-1111-1111-1111-111111111111");
            var characters = await _characterRepository.GetByCreatorFamilyAsync(FamilyId.From(effectiveFamilyId), cancellationToken);

            var responses = characters.Select(character => new CharacterResponse
            {
                Id = character.Id.Value,
                Name = character.Dna.Name,
                Description = character.Dna.Description,
                Appearance = character.Dna.Appearance,
                Personality = character.Dna.Personality,
                IsPublic = character.IsPublic,
                CreatedAt = character.CreatedAt,
                Traits = new TraitsResponse
                {
                    Courage = character.Dna.BaseTraits.Courage,
                    Creativity = character.Dna.BaseTraits.Creativity,
                    Helpfulness = character.Dna.BaseTraits.Helpfulness,
                    Humor = character.Dna.BaseTraits.Humor,
                    Wisdom = character.Dna.BaseTraits.Wisdom,
                    Curiosity = character.Dna.BaseTraits.Curiosity,
                    Empathy = character.Dna.BaseTraits.Empathy,
                    Persistence = character.Dna.BaseTraits.Persistence
                }
            }).ToList();

            _logger.LogInformation("Gefunden {Count} Charaktere für Familie {FamilyId}", responses.Count, effectiveFamilyId);

            return Ok(responses);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fehler beim Laden der Charaktere");
            return StatusCode(500, new { error = "Fehler beim Laden der Charaktere" });
        }
    }
}

// DTOs
public class CreateCharacterRequest
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Appearance { get; set; } = string.Empty;
    public string Personality { get; set; } = string.Empty;
    public Guid FamilyId { get; set; }
    public int MinAge { get; set; } = 3;
    public int MaxAge { get; set; } = 12;
    public int Courage { get; set; } = 50;
    public int Creativity { get; set; } = 50;
    public int Helpfulness { get; set; } = 50;
    public int Humor { get; set; } = 50;
    public int Wisdom { get; set; } = 50;
    public int Curiosity { get; set; } = 50;
    public int Empathy { get; set; } = 50;
    public int Persistence { get; set; } = 50;
}

public class CharacterResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Appearance { get; set; } = string.Empty;
    public string Personality { get; set; } = string.Empty;
    public bool IsPublic { get; set; }
    public DateTime CreatedAt { get; set; }
    public TraitsResponse Traits { get; set; } = new();
}

public class TraitsResponse
{
    public int Courage { get; set; }
    public int Creativity { get; set; }
    public int Helpfulness { get; set; }
    public int Humor { get; set; }
    public int Wisdom { get; set; }
    public int Curiosity { get; set; }
    public int Empathy { get; set; }
    public int Persistence { get; set; }
}
