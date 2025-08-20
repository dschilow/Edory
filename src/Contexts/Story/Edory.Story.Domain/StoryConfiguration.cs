using System;
using System.Collections.Generic;
using System.Linq;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain;

/// <summary>
/// Konfiguration für die Story-Generierung
/// </summary>
public sealed class StoryConfiguration : ValueObject
{
    public StoryGenre Genre { get; }
    public StoryLength Length { get; }
    public int TargetAge { get; } // Zielgruppenalter
    public string[] Keywords { get; } // Schlüsselwörter die eingebaut werden sollen
    public string? Setting { get; } // Schauplatz/Umgebung
    public string? Mood { get; } // Stimmung (fröhlich, spannend, ruhig, etc.)
    public bool IncludeMoralLesson { get; } // Soll eine moralische Lektion enthalten sein
    public string? LearningObjective { get; } // Spezifisches Lernziel
    public int CreativityLevel { get; } // 1-10, wie kreativ/ungewöhnlich soll die Geschichte sein
    
    private StoryConfiguration(
        StoryGenre genre,
        StoryLength length,
        int targetAge,
        string[] keywords,
        string? setting,
        string? mood,
        bool includeMoralLesson,
        string? learningObjective,
        int creativityLevel)
    {
        Genre = genre;
        Length = length;
        TargetAge = targetAge;
        Keywords = keywords;
        Setting = setting;
        Mood = mood;
        IncludeMoralLesson = includeMoralLesson;
        LearningObjective = learningObjective;
        CreativityLevel = creativityLevel;
    }
    
    public static StoryConfiguration Create(
        StoryGenre genre = StoryGenre.Adventure,
        StoryLength length = StoryLength.Medium,
        int targetAge = 7,
        string[]? keywords = null,
        string? setting = null,
        string? mood = null,
        bool includeMoralLesson = true,
        string? learningObjective = null,
        int creativityLevel = 5)
    {
        if (targetAge < 3 || targetAge > 16)
            throw new ArgumentException("Zielgruppenalter muss zwischen 3 und 16 Jahren liegen", nameof(targetAge));
        
        if (creativityLevel < 1 || creativityLevel > 10)
            throw new ArgumentException("Kreativitätslevel muss zwischen 1 und 10 liegen", nameof(creativityLevel));
        
        return new StoryConfiguration(
            genre,
            length,
            targetAge,
            keywords ?? Array.Empty<string>(),
            setting,
            mood,
            includeMoralLesson,
            learningObjective,
            creativityLevel);
    }
    
    /// <summary>
    /// Erstellt eine Konfiguration für Lerngeschichten
    /// </summary>
    public static StoryConfiguration ForLearning(
        string learningObjective,
        int targetAge,
        StoryGenre genre = StoryGenre.Learning,
        string[]? keywords = null)
    {
        if (string.IsNullOrWhiteSpace(learningObjective))
            throw new ArgumentException("Lernziel darf nicht leer sein", nameof(learningObjective));
        
        return Create(
            genre: genre,
            length: StoryLength.Medium,
            targetAge: targetAge,
            keywords: keywords,
            includeMoralLesson: true,
            learningObjective: learningObjective,
            creativityLevel: 6);
    }
    
    /// <summary>
    /// Berechnet die geschätzte Wortanzahl basierend auf der Länge
    /// </summary>
    public int GetEstimatedWordCount()
    {
        return Length switch
        {
            StoryLength.Short => 400,
            StoryLength.Medium => 750,
            StoryLength.Long => 1250,
            StoryLength.Series => 800, // Pro Kapitel
            _ => 750
        };
    }
    
    /// <summary>
    /// Gibt die empfohlene Vorlesezeit in Minuten zurück
    /// </summary>
    public int GetEstimatedReadingTime()
    {
        return Length switch
        {
            StoryLength.Short => 3,
            StoryLength.Medium => 6,
            StoryLength.Long => 12,
            StoryLength.Series => 7, // Pro Kapitel
            _ => 6
        };
    }
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Genre;
        yield return Length;
        yield return TargetAge;
        yield return string.Join(",", Keywords.OrderBy(k => k));
        yield return Setting;
        yield return Mood;
        yield return IncludeMoralLesson;
        yield return LearningObjective;
        yield return CreativityLevel;
    }
}
