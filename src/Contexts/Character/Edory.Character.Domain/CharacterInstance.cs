using System;
using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;
using Edory.Character.Domain.Events;

namespace Edory.Character.Domain;

/// <summary>
/// Charakter-Instanz - Eine spezifische Incarnation eines Charakters in einer Familie
/// Entwickelt sich basierend auf den Erfahrungen in dieser Familie
/// KORRIGIERTE VERSION ohne EF Tracking-Probleme
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
    
    private CharacterInstance() : base(CharacterInstanceId.From(Guid.Empty)) 
    { 
        // Für EF Core - Parameter werden durch EF gesetzt
    }
    
    /// <summary>
    /// Erstellt eine neue Charakter-Instanz basierend auf einem Charakter-Template
    /// KORRIGIERTE VERSION
    /// </summary>
    public static CharacterInstance CreateFromCharacter(
        Character character,
        FamilyId ownerFamilyId)
    {
        if (character == null)
            throw new ArgumentNullException(nameof(character));
            
        if (ownerFamilyId == null)
            throw new ArgumentNullException(nameof(ownerFamilyId));

        var instanceId = CharacterInstanceId.New();
        var now = DateTime.UtcNow;
        
        // Erstelle eine Kopie der DNA für diese Instanz
        var baseDnaCopy = CharacterDna.Create(
            character.Dna.Name,
            character.Dna.Description,
            character.Dna.BaseTraits, // Traits werden kopiert, nicht referenziert
            character.Dna.Appearance,
            character.Dna.Personality,
            character.Dna.MinAge,
            character.Dna.MaxAge
        );

        return new CharacterInstance(
            instanceId,
            character.Id,
            ownerFamilyId,
            baseDnaCopy,
            now);
    }
    
    /// <summary>
    /// Erstellt die Original-Instanz für den Ersteller des Charakters
    /// NEUE METHODE
    /// </summary>
    public static CharacterInstance CreateOriginal(
        Character character,
        FamilyId creatorFamilyId)
    {
        if (character == null)
            throw new ArgumentNullException(nameof(character));
            
        if (creatorFamilyId == null)
            throw new ArgumentNullException(nameof(creatorFamilyId));

        if (character.CreatorFamilyId != creatorFamilyId)
            throw new ArgumentException("Nur die Ersteller-Familie kann die Original-Instanz erstellen");

        return CreateFromCharacter(character, creatorFamilyId);
    }
    
    /// <summary>
    /// Entwickelt die Eigenschaften basierend auf Geschichtserfahrungen
    /// </summary>
    public void EvolveTraits(
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
            courageChange,
            creativityChange,
            helpfulnessChange,
            humorChange,
            wisdomChange,
            curiosityChange,
            empathyChange,
            persistenceChange);
            
        ExperienceCount++;
        LastInteractionAt = DateTime.UtcNow;
        
        AddDomainEvent(new CharacterTraitsEvolvedEvent(
            Id, OriginalCharacterId, OwnerFamilyId, oldTraits, CurrentTraits, ExperienceCount));
    }
    
    /// <summary>
    /// Setzt einen benutzerdefinierten Namen für den Charakter
    /// </summary>
    public void SetCustomName(string? customName)
    {
        if (!string.IsNullOrWhiteSpace(customName) && customName.Length > 100)
            throw new ArgumentException("Custom Name darf nicht länger als 100 Zeichen sein");
            
        CustomName = string.IsNullOrWhiteSpace(customName) ? null : customName.Trim();
        LastInteractionAt = DateTime.UtcNow;
    }
    
    /// <summary>
    /// Aktualisiert die letzte Interaktionszeit
    /// </summary>
    public void RecordInteraction()
    {
        LastInteractionAt = DateTime.UtcNow;
    }
    
    /// <summary>
    /// Gibt den effektiven Namen zurück (Custom Name oder Original Name)
    /// </summary>
    public string GetDisplayName()
    {
        return !string.IsNullOrWhiteSpace(CustomName) ? CustomName : BaseDna.Name;
    }
    
    /// <summary>
    /// Berechnet die Entwicklung der Eigenschaften seit der Erstellung
    /// </summary>
    public CharacterTraits GetTraitEvolution()
    {
        return CharacterTraits.Create(
            CurrentTraits.Courage - BaseDna.BaseTraits.Courage,
            CurrentTraits.Creativity - BaseDna.BaseTraits.Creativity,
            CurrentTraits.Helpfulness - BaseDna.BaseTraits.Helpfulness,
            CurrentTraits.Humor - BaseDna.BaseTraits.Humor,
            CurrentTraits.Wisdom - BaseDna.BaseTraits.Wisdom,
            CurrentTraits.Curiosity - BaseDna.BaseTraits.Curiosity,
            CurrentTraits.Empathy - BaseDna.BaseTraits.Empathy,
            CurrentTraits.Persistence - BaseDna.BaseTraits.Persistence
        );
    }
}