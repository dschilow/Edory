using System;
using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;
using Edory.Character.Domain.Events;

namespace Edory.Character.Domain;

/// <summary>
/// Charakter Aggregate Root - Basis-Template für einen Charakter
/// Dies ist das "Master"-Template, das zwischen Familien geteilt werden kann
/// </summary>
public sealed class Character : AggregateRoot<CharacterId>
{
    public CharacterDna Dna { get; private set; }
    public FamilyId CreatorFamilyId { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public bool IsPublic { get; private set; } // Kann von anderen Familien adoptiert werden
    public int AdoptionCount { get; private set; } // Wie oft wurde dieser Charakter adoptiert
    
    private Character(
        CharacterId id,
        CharacterDna dna,
        FamilyId creatorFamilyId,
        DateTime createdAt) : base(id)
    {
        Dna = dna;
        CreatorFamilyId = creatorFamilyId;
        CreatedAt = createdAt;
        IsPublic = false;
        AdoptionCount = 0;
        
        AddDomainEvent(new CharacterCreatedEvent(Id, dna, creatorFamilyId));
    }
    
    private Character() { } // Für EF Core
    
    /// <summary>
    /// Erstellt einen neuen Charakter
    /// </summary>
    public static Character Create(
        CharacterDna dna,
        FamilyId creatorFamilyId)
    {
        return new Character(
            CharacterId.New(),
            dna,
            creatorFamilyId,
            DateTime.UtcNow);
    }
    
    /// <summary>
    /// Macht den Charakter öffentlich verfügbar für andere Familien
    /// </summary>
    public void MakePublic()
    {
        if (IsPublic) return;
        
        IsPublic = true;
        AddDomainEvent(new CharacterMadePublicEvent(Id, CreatorFamilyId));
    }
    
    /// <summary>
    /// Macht den Charakter wieder privat (nur wenn noch keine Adoptionen)
    /// </summary>
    public void MakePrivate()
    {
        if (!IsPublic) return;
        
        if (AdoptionCount > 0)
            throw new InvalidOperationException("Charakter kann nicht mehr privat gemacht werden, da er bereits adoptiert wurde");
        
        IsPublic = false;
        AddDomainEvent(new CharacterMadePrivateEvent(Id, CreatorFamilyId));
    }
    
    /// <summary>
    /// Registriert eine Adoption dieses Charakters
    /// </summary>
    public void RegisterAdoption(FamilyId adoptingFamilyId)
    {
        if (!IsPublic)
            throw new InvalidOperationException("Privater Charakter kann nicht adoptiert werden");
        
        AdoptionCount++;
        AddDomainEvent(new CharacterAdoptedEvent(Id, CreatorFamilyId, adoptingFamilyId, AdoptionCount));
    }
    
    /// <summary>
    /// Aktualisiert die Charakter-DNA (nur für Ersteller)
    /// </summary>
    public void UpdateDna(CharacterDna newDna, FamilyId updatingFamilyId)
    {
        if (CreatorFamilyId != updatingFamilyId)
            throw new InvalidOperationException("Nur die Ersteller-Familie kann die Charakter-DNA ändern");
        
        var oldDna = Dna;
        Dna = newDna;
        
        AddDomainEvent(new CharacterDnaUpdatedEvent(Id, oldDna, newDna, updatingFamilyId));
    }
}
