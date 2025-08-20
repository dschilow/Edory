using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.SharedKernel.ValueObjects;

/// <summary>
/// Charakter-Eigenschaften, die sich über Zeit entwickeln können
/// Werte von 0-100, wobei 50 neutral ist
/// </summary>
public sealed class CharacterTraits : ValueObject
{
    public int Courage { get; private set; } // Mut
    public int Creativity { get; private set; } // Kreativität
    public int Helpfulness { get; private set; } // Hilfsbereitschaft
    public int Humor { get; private set; } // Humor
    public int Wisdom { get; private set; } // Weisheit
    public int Curiosity { get; private set; } // Neugier
    public int Empathy { get; private set; } // Empathie
    public int Persistence { get; private set; } // Ausdauer
    
    private CharacterTraits(
        int courage, 
        int creativity, 
        int helpfulness, 
        int humor, 
        int wisdom, 
        int curiosity, 
        int empathy, 
        int persistence)
    {
        Courage = courage;
        Creativity = creativity;
        Helpfulness = helpfulness;
        Humor = humor;
        Wisdom = wisdom;
        Curiosity = curiosity;
        Empathy = empathy;
        Persistence = persistence;
    }
    
    // Für EF Core
    private CharacterTraits() { }
    
    public static CharacterTraits Create(
        int courage = 50,
        int creativity = 50,
        int helpfulness = 50,
        int humor = 50,
        int wisdom = 50,
        int curiosity = 50,
        int empathy = 50,
        int persistence = 50)
    {
        ValidateTrait(courage, nameof(courage));
        ValidateTrait(creativity, nameof(creativity));
        ValidateTrait(helpfulness, nameof(helpfulness));
        ValidateTrait(humor, nameof(humor));
        ValidateTrait(wisdom, nameof(wisdom));
        ValidateTrait(curiosity, nameof(curiosity));
        ValidateTrait(empathy, nameof(empathy));
        ValidateTrait(persistence, nameof(persistence));
        
        return new CharacterTraits(courage, creativity, helpfulness, humor, wisdom, curiosity, empathy, persistence);
    }
    
    /// <summary>
    /// Entwickelt die Eigenschaften basierend auf Erfahrungen weiter
    /// </summary>
    public CharacterTraits Evolve(
        int courageChange = 0,
        int creativityChange = 0,
        int helpfulnessChange = 0,
        int humorChange = 0,
        int wisdomChange = 0,
        int curiosityChange = 0,
        int empathyChange = 0,
        int persistenceChange = 0)
    {
        return Create(
            Math.Clamp(Courage + courageChange, 0, 100),
            Math.Clamp(Creativity + creativityChange, 0, 100),
            Math.Clamp(Helpfulness + helpfulnessChange, 0, 100),
            Math.Clamp(Humor + humorChange, 0, 100),
            Math.Clamp(Wisdom + wisdomChange, 0, 100),
            Math.Clamp(Curiosity + curiosityChange, 0, 100),
            Math.Clamp(Empathy + empathyChange, 0, 100),
            Math.Clamp(Persistence + persistenceChange, 0, 100)
        );
    }
    
    private static void ValidateTrait(int value, string name)
    {
        if (value < 0 || value > 100)
            throw new ArgumentOutOfRangeException(name, "Eigenschaftswerte müssen zwischen 0 und 100 liegen");
    }
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Courage;
        yield return Creativity;
        yield return Helpfulness;
        yield return Humor;
        yield return Wisdom;
        yield return Curiosity;
        yield return Empathy;
        yield return Persistence;
    }
}
