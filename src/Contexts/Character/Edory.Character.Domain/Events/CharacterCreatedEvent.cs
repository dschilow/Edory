using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Neuer Charakter wurde erstellt
/// </summary>
public sealed record CharacterCreatedEvent(
    CharacterId CharacterId,
    CharacterDna Dna,
    FamilyId CreatorFamilyId
) : DomainEvent;
