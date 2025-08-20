using System;
using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;
using Edory.Character.Domain.Events;

namespace Edory.Character.Domain;

/// <summary>
/// Charakter-Instanz - Eine spezifische Incarnation eines Charakters in einer Familie
/// Entwickelt sich basierend auf den Erfahrungen in dieser Familie
/// </summary>
public sealed class CharacterInstance : AggregateRoot<CharacterInstanceId>
{
    public CharacterId OriginalCharacterId { get; private set; }
    public FamilyId OwnerFamilyId { get; private set; }
    public CharacterDna BaseDna { get; private set; } // Unveränderliche Basis-DNA
    public CharacterTraits CurrentTraits { get; private set; } // Entwickelte Eigenschaften
    public DateTime CreatedAt { get; private set; }
    public DateTime LastInteractionAt { get; private set; }
    public int ExperienceCount { get; private set; } // Anzahl der Geschichten/Erfahrungen
    public string? CustomName { get; private set; } // Optional: Familie kann Charakter umbenennen
    
    private CharacterInstance(
        CharacterInstanceId id,
        CharacterId originalCharacterId,
        FamilyId ownerFamilyId,
        CharacterDna baseDna,
        DateTime createdAt) : base(id)
    {
        OriginalCharacterId = originalCharacterId;
        OwnerFamilyId = ownerFamilyId;
        BaseDna = baseDna;
        CurrentTraits = baseDna.BaseTraits; // Startet mit Basis-Eigenschaften
        CreatedAt = createdAt;
        LastInteractionAt = createdAt;
        ExperienceCount = 0;
        
        AddDomainEvent(new CharacterInstanceCreatedEvent(
            Id, originalCharacterId, ownerFamilyId, baseDna));
    }
    
    private CharacterInstance() { } // Für EF Core
    
    /// <summary>
    /// Erstellt eine neue Charakter-Instanz basierend auf einem Charakter-Template
    /// </summary>
    public static CharacterInstance CreateFromCharacter(
        Character character,
        FamilyId ownerFamilyId)
    {
        if (!character.IsPublic && character.CreatorFamilyId != ownerFamilyId)
            throw new InvalidOperationException("Privater Charakter kann nur von der Ersteller-Familie instanziiert werden");
        
        return new CharacterInstance(
            CharacterInstanceId.New(),
            character.Id,
            ownerFamilyId,
            character.Dna,
            DateTime.UtcNow);
    }
    
    /// <summary>
    /// Erstellt eine direkte Instanz für die Ersteller-Familie
    /// </summary>
    public static CharacterInstance CreateOriginal(
        Character character,
        FamilyId creatorFamilyId)
    {
        if (character.CreatorFamilyId != creatorFamilyId)
            throw new InvalidOperationException("Nur die Ersteller-Familie kann die Original-Instanz erstellen");
        
        return new CharacterInstance(
            CharacterInstanceId.New(),
            character.Id,
            creatorFamilyId,
            character.Dna,
            DateTime.UtcNow);
    }
    
    /// <summary>
    /// Entwickelt die Charaktereigenschaften basierend auf einer Erfahrung
    /// </summary>
    public void EvolveFromExperience(
        int courageChange = 0,
        int creativityChange = 0,
        int helpfulnessChange = 0,
        int humorChange = 0,
        int wisdomChange = 0,
        int curiosityChange = 0,
        int empathyChange = 0,
        int persistenceChange = 0)
    {
        var oldTraits = CurrentTraits;
        CurrentTraits = CurrentTraits.Evolve(
            courageChange, creativityChange, helpfulnessChange, 
            humorChange, wisdomChange, curiosityChange, 
            empathyChange, persistenceChange);
        
        ExperienceCount++;
        LastInteractionAt = DateTime.UtcNow;
        
        AddDomainEvent(new CharacterTraitsEvolvedEvent(
            Id, OriginalCharacterId, OwnerFamilyId, oldTraits, CurrentTraits, ExperienceCount));
    }
    
    /// <summary>
    /// Setzt einen benutzerdefinierten Namen für diese Instanz
    /// </summary>
    public void SetCustomName(string? customName)
    {
        if (!string.IsNullOrWhiteSpace(customName) && customName.Length > 50)
            throw new ArgumentException("Benutzerdefinierter Name darf maximal 50 Zeichen lang sein");
        
        var oldName = CustomName;
        CustomName = string.IsNullOrWhiteSpace(customName) ? null : customName.Trim();
        
        AddDomainEvent(new CharacterInstanceRenamedEvent(
            Id, OriginalCharacterId, OwnerFamilyId, oldName, CustomName));
    }
    
    /// <summary>
    /// Aktualisiert den Zeitpunkt der letzten Interaktion
    /// </summary>
    public void RecordInteraction()
    {
        LastInteractionAt = DateTime.UtcNow;
        AddDomainEvent(new CharacterInteractionRecordedEvent(
            Id, OriginalCharacterId, OwnerFamilyId, LastInteractionAt));
    }
    
    /// <summary>
    /// Gibt den anzuzeigenden Namen zurück (Custom oder Original)
    /// </summary>
    public string GetDisplayName()
    {
        return !string.IsNullOrWhiteSpace(CustomName) ? CustomName : BaseDna.Name;
    }
}
