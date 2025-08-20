using System;
using System.Collections.Generic;
using System.Linq;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain;

/// <summary>
/// Emotionaler Kontext einer Erinnerung
/// Beeinflusst wie lebhaft und wichtig die Erinnerung ist
/// </summary>
public sealed class EmotionalContext : ValueObject
{
    public int Joy { get; } // Freude (0-100)
    public int Sadness { get; } // Trauer (0-100)
    public int Fear { get; } // Angst (0-100)
    public int Anger { get; } // Ärger (0-100)
    public int Surprise { get; } // Überraschung (0-100)
    public int Pride { get; } // Stolz (0-100)
    public int Excitement { get; } // Aufregung (0-100)
    public int Calmness { get; } // Ruhe (0-100)
    
    private EmotionalContext(
        int joy, int sadness, int fear, int anger, 
        int surprise, int pride, int excitement, int calmness)
    {
        Joy = joy;
        Sadness = sadness;
        Fear = fear;
        Anger = anger;
        Surprise = surprise;
        Pride = pride;
        Excitement = excitement;
        Calmness = calmness;
    }
    
    public static EmotionalContext Create(
        int joy = 0, int sadness = 0, int fear = 0, int anger = 0,
        int surprise = 0, int pride = 0, int excitement = 0, int calmness = 0)
    {
        ValidateEmotion(joy, nameof(joy));
        ValidateEmotion(sadness, nameof(sadness));
        ValidateEmotion(fear, nameof(fear));
        ValidateEmotion(anger, nameof(anger));
        ValidateEmotion(surprise, nameof(surprise));
        ValidateEmotion(pride, nameof(pride));
        ValidateEmotion(excitement, nameof(excitement));
        ValidateEmotion(calmness, nameof(calmness));
        
        return new EmotionalContext(joy, sadness, fear, anger, surprise, pride, excitement, calmness);
    }
    
    /// <summary>
    /// Neutraler emotionaler Zustand
    /// </summary>
    public static EmotionalContext Neutral => Create(calmness: 50);
    
    /// <summary>
    /// Berechnet die emotionale Intensität (0-100)
    /// </summary>
    public int GetIntensity()
    {
        var emotions = new[] { Joy, Sadness, Fear, Anger, Surprise, Pride, Excitement };
        var maxEmotion = emotions.Length > 0 ? emotions.Max() : 0;
        return Math.Max(maxEmotion - Calmness, 0);
    }
    
    /// <summary>
    /// Bestimmt die dominante Emotion
    /// </summary>
    public string GetDominantEmotion()
    {
        var emotions = new Dictionary<string, int>
        {
            { "Joy", Joy },
            { "Sadness", Sadness },
            { "Fear", Fear },
            { "Anger", Anger },
            { "Surprise", Surprise },
            { "Pride", Pride },
            { "Excitement", Excitement },
            { "Calmness", Calmness }
        };
        
        return emotions.OrderByDescending(e => e.Value).First().Key;
    }
    
    private static void ValidateEmotion(int value, string name)
    {
        if (value < 0 || value > 100)
            throw new ArgumentOutOfRangeException(name, "Emotionswerte müssen zwischen 0 und 100 liegen");
    }
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Joy;
        yield return Sadness;
        yield return Fear;
        yield return Anger;
        yield return Surprise;
        yield return Pride;
        yield return Excitement;
        yield return Calmness;
    }
}
