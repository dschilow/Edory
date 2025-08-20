using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Charakter wurde von einer Familie adoptiert
/// </summary>
public sealed record CharacterAdoptedEvent(
    CharacterId CharacterId,
    FamilyId CreatorFamilyId,
    FamilyId AdoptingFamilyId,
    int TotalAdoptionCount
) : DomainEvent;
