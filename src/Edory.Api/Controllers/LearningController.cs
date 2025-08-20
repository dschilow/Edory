using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Edory.Learning.Domain;

namespace Edory.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LearningController : ControllerBase
{
    /// <summary>
    /// Erstellt ein neues Lernziel
    /// </summary>
    [HttpPost("objectives")]
    public async Task<ActionResult<LearningObjectiveResponse>> CreateLearningObjective([FromBody] CreateLearningObjectiveRequest request)
    {
        try
        {
            var objective = LearningObjective.Create(
                request.Title,
                request.Description,
                request.Category,
                request.Level,
                request.TargetAge,
                request.FamilyId,
                request.Priority);
            
            if (request.Keywords?.Length > 0)
            {
                objective.AddKeywords(request.Keywords);
            }
            
            if (request.SuccessCriteria?.Length > 0)
            {
                objective.AddSuccessCriteria(request.SuccessCriteria);
            }
            
            var response = new LearningObjectiveResponse
            {
                Id = objective.Id.Value,
                Title = objective.Title,
                Description = objective.Description,
                Category = objective.Category.ToString(),
                Level = objective.Level.ToString(),
                TargetAge = objective.TargetAge,
                Priority = objective.Priority,
                IsActive = objective.IsActive,
                CreatedAt = objective.CreatedAt,
                Keywords = objective.Keywords.ToArray(),
                SuccessCriteria = objective.SuccessCriteria.ToArray(),
                ComplexityScore = objective.GetComplexityScore()
            };
            
            return CreatedAtAction(nameof(GetLearningObjective), new { id = objective.Id.Value }, response);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
    
    /// <summary>
    /// Holt ein Lernziel nach ID
    /// </summary>
    [HttpGet("objectives/{id}")]
    public async Task<ActionResult<LearningObjectiveResponse>> GetLearningObjective(Guid id)
    {
        // Mock-Response für MVP-Demo
        var mockResponse = new LearningObjectiveResponse
        {
            Id = id,
            Title = "Mut entwickeln",
            Description = "Lernen, mutig zu sein und neue Herausforderungen anzunehmen",
            Category = "EmotionalDevelopment",
            Level = "Basic",
            TargetAge = 6,
            Priority = 8,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-3),
            Keywords = new[] { "mut", "herausforderung", "selbstvertrauen" },
            SuccessCriteria = new[] { "Zeigt Initiative bei neuen Aktivitäten", "Überwindet kleine Ängste" },
            ComplexityScore = 6
        };
        
        return Ok(mockResponse);
    }
    
    /// <summary>
    /// Listet alle Lernziele einer Familie auf
    /// </summary>
    [HttpGet("objectives/family/{familyId}")]
    public async Task<ActionResult<List<LearningObjectiveResponse>>> GetFamilyLearningObjectives(Guid familyId)
    {
        // Mock-Response für MVP-Demo
        var mockObjectives = new List<LearningObjectiveResponse>
        {
            new LearningObjectiveResponse
            {
                Id = Guid.NewGuid(),
                Title = "Freundschaft verstehen",
                Description = "Lernen, was eine gute Freundschaft ausmacht",
                Category = "SocialSkills",
                Level = "Basic",
                TargetAge = 5,
                Priority = 7,
                IsActive = true,
                CreatedAt = DateTime.UtcNow.AddDays(-5),
                Keywords = new[] { "freundschaft", "teilen", "zusammenarbeiten" },
                SuccessCriteria = new[] { "Kann Freundschaftsregeln erklären", "Teilt gerne mit anderen" },
                ComplexityScore = 5
            },
            new LearningObjectiveResponse
            {
                Id = Guid.NewGuid(),
                Title = "Zahlen bis 20",
                Description = "Sicher rechnen und zählen bis 20",
                Category = "Mathematics",
                Level = "Intermediate",
                TargetAge = 7,
                Priority = 9,
                IsActive = true,
                CreatedAt = DateTime.UtcNow.AddDays(-2),
                Keywords = new[] { "zahlen", "rechnen", "zählen", "mathematik" },
                SuccessCriteria = new[] { "Zählt flüssig bis 20", "Rechnet einfache Additions- und Subtraktionsaufgaben" },
                ComplexityScore = 7
            }
        };
        
        return Ok(mockObjectives);
    }
    
    /// <summary>
    /// Generiert eine Lerngeschichte basierend auf einem Lernziel
    /// </summary>
    [HttpPost("objectives/{objectiveId}/generate-story")]
    public async Task<ActionResult<GeneratedLearningStoryResponse>> GenerateLearningStory(
        Guid objectiveId, 
        [FromBody] GenerateLearningStoryRequest request)
    {
        // Mock-Response für MVP-Demo
        var mockResponse = new GeneratedLearningStoryResponse
        {
            StoryTitle = $"Wie {request.CharacterName} {GetMockLearningTitle(objectiveId)}",
            StoryContent = GenerateMockLearningStory(request.CharacterName, objectiveId),
            LearningObjectiveId = objectiveId,
            TargetAge = request.TargetAge,
            EstimatedReadingTime = 7,
            LearningPoints = GetMockLearningPoints(objectiveId)
        };
        
        return Ok(mockResponse);
    }
    
    private string GetMockLearningTitle(Guid objectiveId)
    {
        return "Mut fand";
    }
    
    private string GenerateMockLearningStory(string characterName, Guid objectiveId)
    {
        return $@"{characterName} war ein wenig nervös, als er das große, dunkle Haus am Ende der Straße sah. 
Alle anderen Kinder sagten, es sei gruselig, aber {characterName} war neugierig.

'Ich werde mutig sein', dachte {characterName}. 'Manchmal muss man seine Ängste überwinden, um etwas Neues zu entdecken.'

Schritt für Schritt ging {characterName} näher. Das Herz klopfte schnell, aber {characterName} atmete tief durch und ging weiter.

Als {characterName} an der Tür klopfte, öffnete eine freundliche alte Dame. 'Oh, wie schön! Endlich kommt mich jemand besuchen. 
Ich bin Frau Miller und ich backe die besten Kekse der ganzen Nachbarschaft!'

{characterName} lächelte. Manchmal führen mutige Entscheidungen zu den wunderbarsten Überraschungen.

Von diesem Tag an besuchte {characterName} regelmäßig Frau Miller und lernte, dass Mut bedeutet, 
auch dann weiterzumachen, wenn man ein bisschen Angst hat.";
    }
    
    private string[] GetMockLearningPoints(Guid objectiveId)
    {
        return new[]
        {
            "Mut bedeutet nicht, keine Angst zu haben, sondern trotz Angst zu handeln",
            "Neue Erfahrungen können zu wunderbaren Entdeckungen führen",
            "Manchmal sind unsere Ängste unbegründet",
            "Kleine mutige Schritte führen zu großen Veränderungen"
        };
    }
}

// DTOs
public class CreateLearningObjectiveRequest
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public LearningCategory Category { get; set; }
    public SkillLevel Level { get; set; }
    public int TargetAge { get; set; }
    public Guid FamilyId { get; set; }
    public int Priority { get; set; } = 5;
    public string[]? Keywords { get; set; }
    public string[]? SuccessCriteria { get; set; }
}

public class LearningObjectiveResponse
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
    public int TargetAge { get; set; }
    public int Priority { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public string[] Keywords { get; set; } = Array.Empty<string>();
    public string[] SuccessCriteria { get; set; } = Array.Empty<string>();
    public int ComplexityScore { get; set; }
}

public class GenerateLearningStoryRequest
{
    public Guid CharacterInstanceId { get; set; }
    public string CharacterName { get; set; } = string.Empty;
    public int TargetAge { get; set; }
    public string? Setting { get; set; }
}

public class GeneratedLearningStoryResponse
{
    public string StoryTitle { get; set; } = string.Empty;
    public string StoryContent { get; set; } = string.Empty;
    public Guid LearningObjectiveId { get; set; }
    public int TargetAge { get; set; }
    public int EstimatedReadingTime { get; set; }
    public string[] LearningPoints { get; set; } = Array.Empty<string>();
}
