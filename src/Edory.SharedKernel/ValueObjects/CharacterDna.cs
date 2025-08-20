using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.SharedKernel.ValueObjects;

/// <summary>
/// Charakter-DNA definiert die Basis-Eigenschaften eines Charakters
/// Diese werden beim Teilen zwischen Familien übertragen
/// </summary>
public sealed class CharacterDna : ValueObject
{
    public string Name { get; }
    public string Description { get; }
    public CharacterTraits BaseTraits { get; }
    public string Appearance { get; }
    public string Personality { get; }
    public int MinAge { get; } // Minimales Alter für Zielgruppe
    public int MaxAge { get; } // Maximales Alter für Zielgruppe
    
    private CharacterDna(
        string name, 
        string description, 
        CharacterTraits baseTraits, 
        string appearance, 
        string personality,
        int minAge,
        int maxAge)
    {
        Name = name;
        Description = description;
        BaseTraits = baseTraits;
        Appearance = appearance;
        Personality = personality;
        MinAge = minAge;
        MaxAge = maxAge;
    }
    
    public static CharacterDna Create(
        string name, 
        string description, 
        CharacterTraits baseTraits, 
        string appearance, 
        string personality,
        int minAge = 3,
        int maxAge = 12)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name darf nicht leer sein", nameof(name));
            
        if (string.IsNullOrWhiteSpace(description))
            throw new ArgumentException("Beschreibung darf nicht leer sein", nameof(description));
            
        if (minAge < 0 || maxAge < minAge)
            throw new ArgumentException("Ungültiges Altersbereich");
        
        return new CharacterDna(name, description, baseTraits, appearance, personality, minAge, maxAge);
    }
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Name;
        yield return Description;
        yield return BaseTraits;
        yield return Appearance;
        yield return Personality;
        yield return MinAge;
        yield return MaxAge;
    }
}
