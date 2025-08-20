using System;
using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;
using Edory.Character.Domain.Events;

namespace Edory.Character.Domain;

/// <summary>
/// Charakter-Instanz - VEREINFACHTE VERSION ohne EF Owned Types
/// Speichert Traits als primitive Properties um EF Tracking-Probleme zu vermeiden
/// </summary>
public sealed class CharacterInstance : AggregateRoot<CharacterInstanceId>
{
    // Basis-Eigenschaften
    public CharacterId OriginalCharacterId { get; private set; }
    public FamilyId OwnerFamilyId { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime LastInteractionAt { get; private set; }
    public int ExperienceCount { get; private set; }
    public string? CustomName { get; private set; }

    // Base DNA als primitive Properties (KEINE Owned Types)
    public string BaseName { get; private set; } = string.Empty;
    public string BaseDescription { get; private set; } = string.Empty;
    public string BaseAppearance { get; private set; } = string.Empty;
    public string BasePersonality { get; private set; } = string.Empty;
    public int BaseMinAge { get; private set; }
    public int BaseMaxAge { get; private set; }

    // Base Traits als primitive Properties 
    public int BaseTraitsCourage { get; private set; }
    public int BaseTraitsCreativity { get; private set; }
    public int BaseTraitsHelpfulness { get; private set; }
    public int BaseTraitsHumor { get; private set; }
    public int BaseTraitsWisdom { get; private set; }
    public int BaseTraitsCuriosity { get; private set; }
    public int BaseTraitsEmpathy { get; private set; }
    public int BaseTraitsPersistence { get; private set; }

    // Current Traits als primitive Properties
    public int CurrentCourage { get; private set; }
    public int CurrentCreativity { get; private set; }
    public int CurrentHelpfulness { get; private set; }
    public int CurrentHumor { get; private set; }
    public int CurrentWisdom { get; private set; }
    public int CurrentCuriosity { get; private set; }
    public int CurrentEmpathy { get; private set; }
    public int CurrentPersistence { get; private set; }

    private CharacterInstance(
        CharacterInstanceId id,
        CharacterId originalCharacterId,
        FamilyId ownerFamilyId,
        CharacterDna baseDna,
        DateTime createdAt) : base(id)
    {
        OriginalCharacterId = originalCharacterId;
        OwnerFamilyId = ownerFamilyId;
        CreatedAt = createdAt;
        LastInteractionAt = createdAt;
        ExperienceCount = 0;

        // Base DNA kopieren (als primitive Properties)
        BaseName = baseDna.Name;
        BaseDescription = baseDna.Description;
        BaseAppearance = baseDna.Appearance;
        BasePersonality = baseDna.Personality;
        BaseMinAge = baseDna.MinAge;
        BaseMaxAge = baseDna.MaxAge;

        // Base Traits kopieren
        BaseTraitsCourage = baseDna.BaseTraits.Courage;
        BaseTraitsCreativity = baseDna.BaseTraits.Creativity;
        BaseTraitsHelpfulness = baseDna.BaseTraits.Helpfulness;
        BaseTraitsHumor = baseDna.BaseTraits.Humor;
        BaseTraitsWisdom = baseDna.BaseTraits.Wisdom;
        BaseTraitsCuriosity = baseDna.BaseTraits.Curiosity;
        BaseTraitsEmpathy = baseDna.BaseTraits.Empathy;
        BaseTraitsPersistence = baseDna.BaseTraits.Persistence;

        // Current Traits = Base Traits (zu Beginn)
        CurrentCourage = baseDna.BaseTraits.Courage;
        CurrentCreativity = baseDna.BaseTraits.Creativity;
        CurrentHelpfulness = baseDna.BaseTraits.Helpfulness;
        CurrentHumor = baseDna.BaseTraits.Humor;
        CurrentWisdom = baseDna.BaseTraits.Wisdom;
        CurrentCuriosity = baseDna.BaseTraits.Curiosity;
        CurrentEmpathy = baseDna.BaseTraits.Empathy;
        CurrentPersistence = baseDna.BaseTraits.Persistence;
        
        AddDomainEvent(new CharacterInstanceCreatedEvent(
            Id, originalCharacterId, ownerFamilyId, baseDna));
    }
    
    private CharacterInstance() : base(CharacterInstanceId.From(Guid.Empty)) 
    { 
        // Für EF Core - Properties werden von EF gesetzt
    }
    
    /// <summary>
    /// Erstellt eine neue Charakter-Instanz basierend auf einem Charakter-Template
    /// </summary>
    public static CharacterInstance CreateFromCharacter(
        Character character,
        FamilyId ownerFamilyId)
    {
        if (character == null)
            throw new ArgumentNullException(nameof(character));
            
        if (ownerFamilyId == null)
            throw new ArgumentNullException(nameof(ownerFamilyId));

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
    /// Erstellt die Original-Instanz für den Ersteller des Charakters
    /// </summary>
    public static CharacterInstance CreateOriginal(
        Character character,
        FamilyId creatorFamilyId)
    {
        if (character == null)
            throw new ArgumentNullException(nameof(character));
            
        if (character.CreatorFamilyId != creatorFamilyId)
            throw new InvalidOperationException("Nur die Ersteller-Familie kann die Original-Instanz erstellen");

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
        var oldTraits = GetCurrentTraits();
        
        // Apply changes with clamping (0-100)
        CurrentCourage = Math.Clamp(CurrentCourage + courageChange, 0, 100);
        CurrentCreativity = Math.Clamp(CurrentCreativity + creativityChange, 0, 100);
        CurrentHelpfulness = Math.Clamp(CurrentHelpfulness + helpfulnessChange, 0, 100);
        CurrentHumor = Math.Clamp(CurrentHumor + humorChange, 0, 100);
        CurrentWisdom = Math.Clamp(CurrentWisdom + wisdomChange, 0, 100);
        CurrentCuriosity = Math.Clamp(CurrentCuriosity + curiosityChange, 0, 100);
        CurrentEmpathy = Math.Clamp(CurrentEmpathy + empathyChange, 0, 100);
        CurrentPersistence = Math.Clamp(CurrentPersistence + persistenceChange, 0, 100);
            
        ExperienceCount++;
        LastInteractionAt = DateTime.UtcNow;
        
        var newTraits = GetCurrentTraits();
        AddDomainEvent(new CharacterTraitsEvolvedEvent(
            Id, OriginalCharacterId, OwnerFamilyId, oldTraits, newTraits, ExperienceCount));
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
        return !string.IsNullOrWhiteSpace(CustomName) ? CustomName : BaseName;
    }

    /// <summary>
    /// Gibt die Base DNA als Value Object zurück (für Domain Logic)
    /// </summary>
    public CharacterDna GetBaseDna()
    {
        var baseTraits = CharacterTraits.Create(
            BaseTraitsCourage, BaseTraitsCreativity, BaseTraitsHelpfulness, BaseTraitsHumor,
            BaseTraitsWisdom, BaseTraitsCuriosity, BaseTraitsEmpathy, BaseTraitsPersistence);

        return CharacterDna.Create(
            BaseName, BaseDescription, baseTraits, BaseAppearance, BasePersonality, BaseMinAge, BaseMaxAge);
    }

    /// <summary>
    /// Gibt die aktuellen Traits als Value Object zurück (für Domain Logic)
    /// </summary>
    public CharacterTraits GetCurrentTraits()
    {
        return CharacterTraits.Create(
            CurrentCourage, CurrentCreativity, CurrentHelpfulness, CurrentHumor,
            CurrentWisdom, CurrentCuriosity, CurrentEmpathy, CurrentPersistence);
    }

    /// <summary>
    /// Gibt die Base Traits als Value Object zurück
    /// </summary>
    public CharacterTraits GetBaseTraits()
    {
        return CharacterTraits.Create(
            BaseTraitsCourage, BaseTraitsCreativity, BaseTraitsHelpfulness, BaseTraitsHumor,
            BaseTraitsWisdom, BaseTraitsCuriosity, BaseTraitsEmpathy, BaseTraitsPersistence);
    }
    
    /// <summary>
    /// Berechnet die Entwicklung der Eigenschaften seit der Erstellung
    /// </summary>
    public CharacterTraits GetTraitEvolution()
    {
        return CharacterTraits.Create(
            CurrentCourage - BaseTraitsCourage,
            CurrentCreativity - BaseTraitsCreativity,
            CurrentHelpfulness - BaseTraitsHelpfulness,
            CurrentHumor - BaseTraitsHumor,
            CurrentWisdom - BaseTraitsWisdom,
            CurrentCuriosity - BaseTraitsCuriosity,
            CurrentEmpathy - BaseTraitsEmpathy,
            CurrentPersistence - BaseTraitsPersistence
        );
    }
}