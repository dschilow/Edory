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
    public string Name { get; private set; }
    public string Description { get; private set; }
    public CharacterTraits BaseTraits { get; private set; }
    public string Appearance { get; private set; }
    public string Personality { get; private set; }
    public int MinAge { get; private set; } // Minimales Alter für Zielgruppe
    public int MaxAge { get; private set; } // Maximales Alter für Zielgruppe
    
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
    
    // Für EF Core
    private CharacterDna() { }
    
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
