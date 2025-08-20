using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Edory.Story.Domain;

namespace Edory.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StoriesController : ControllerBase
{
    /// <summary>
    /// Generiert eine neue Geschichte für einen Charakter
    /// </summary>
    [HttpPost("generate")]
    public async Task<ActionResult<StoryResponse>> GenerateStory([FromBody] GenerateStoryRequest request)
    {
        try
        {
            // Story-Konfiguration erstellen
            var config = StoryConfiguration.Create(
                request.Genre,
                request.Length,
                request.TargetAge,
                request.Keywords,
                request.Setting,
                request.Mood,
                request.IncludeMoralLesson,
                request.LearningObjective,
                request.CreativityLevel);

            // Für MVP-Demo generieren wir eine Mock-Geschichte
            var mockStoryContent = GenerateMockStory(request);
            
            var story = Edory.Story.Domain.Story.CreateGenerated(
                "Das Abenteuer von " + request.CharacterName,
                mockStoryContent,
                config,
                request.CharacterInstanceId,
                request.FamilyId,
                $"Ein buntes Bild von {request.CharacterName} in einem magischen Wald");
            
            var response = new StoryResponse
            {
                Id = story.Id.Value,
                Title = story.Title,
                Content = story.Content,
                Genre = story.Configuration.Genre.ToString(),
                Length = story.Configuration.Length.ToString(),
                TargetAge = story.Configuration.TargetAge,
                CreatedAt = story.CreatedAt,
                EstimatedReadingTime = story.GetEstimatedReadingTime(),
                IsGenerated = story.IsGenerated
            };
            
            return CreatedAtAction(nameof(GetStory), new { id = story.Id.Value }, response);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
    
    /// <summary>
    /// Holt eine Geschichte nach ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<StoryResponse>> GetStory(Guid id)
    {
        // Mock-Response für MVP-Demo
        var mockResponse = new StoryResponse
        {
            Id = id,
            Title = "Das magische Abenteuer",
            Content = "Es war einmal ein mutiger kleiner Held namens Alex...",
            Genre = "Adventure",
            Length = "Medium",
            TargetAge = 7,
            CreatedAt = DateTime.UtcNow.AddHours(-2),
            EstimatedReadingTime = 6,
            IsGenerated = true
        };
        
        return Ok(mockResponse);
    }
    
    /// <summary>
    /// Listet Geschichten für einen Charakter auf
    /// </summary>
    [HttpGet("character/{characterInstanceId}")]
    public async Task<ActionResult<List<StoryResponse>>> GetStoriesForCharacter(Guid characterInstanceId)
    {
        // Mock-Response für MVP-Demo
        var mockStories = new List<StoryResponse>
        {
            new StoryResponse
            {
                Id = Guid.NewGuid(),
                Title = "Das erste Abenteuer",
                Content = "Kurzer Auszug der Geschichte...",
                Genre = "Adventure",
                Length = "Short",
                TargetAge = 6,
                CreatedAt = DateTime.UtcNow.AddDays(-2),
                EstimatedReadingTime = 3,
                IsGenerated = true
            },
            new StoryResponse
            {
                Id = Guid.NewGuid(),
                Title = "Die magische Freundschaft",
                Content = "Kurzer Auszug der Geschichte...",
                Genre = "Friendship",
                Length = "Medium",
                TargetAge = 7,
                CreatedAt = DateTime.UtcNow.AddDays(-1),
                EstimatedReadingTime = 6,
                IsGenerated = true
            }
        };
        
        return Ok(mockStories);
    }
    
    private string GenerateMockStory(GenerateStoryRequest request)
    {
        return $@"Es war einmal ein wunderbarer Tag, als {request.CharacterName} aufwachte und aus dem Fenster schaute. 
Die Sonne schien hell und {request.CharacterName} fühlte sich bereit für ein neues Abenteuer.

{(request.Setting != null ? $"In {request.Setting} " : "")}entdeckte {request.CharacterName} etwas Ungewöhnliches. 
{(request.Keywords?.Length > 0 ? $"Es hatte etwas mit {string.Join(" und ", request.Keywords)} zu tun. " : "")}

{request.CharacterName} musste mutig sein und zeigte dabei große Kreativität. 
Nach vielen spannenden Erlebnissen lernte {request.CharacterName} eine wichtige Lektion:
{(request.LearningObjective ?? "Freundschaft und Mut sind die wertvollsten Schätze.")}

Und so endete ein weiteres wundervolles Abenteuer von {request.CharacterName}, 
der nun noch weiser und erfahrener war als zuvor.

Ende der Geschichte.";
    }
}

// DTOs
public class GenerateStoryRequest
{
    public Guid CharacterInstanceId { get; set; }
    public Guid FamilyId { get; set; }
    public string CharacterName { get; set; } = string.Empty;
    public StoryGenre Genre { get; set; } = StoryGenre.Adventure;
    public StoryLength Length { get; set; } = StoryLength.Medium;
    public int TargetAge { get; set; } = 7;
    public string[]? Keywords { get; set; }
    public string? Setting { get; set; }
    public string? Mood { get; set; }
    public bool IncludeMoralLesson { get; set; } = true;
    public string? LearningObjective { get; set; }
    public int CreativityLevel { get; set; } = 5;
}

public class StoryResponse
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string Genre { get; set; } = string.Empty;
    public string Length { get; set; } = string.Empty;
    public int TargetAge { get; set; }
    public DateTime CreatedAt { get; set; }
    public int EstimatedReadingTime { get; set; }
    public bool IsGenerated { get; set; }
}
