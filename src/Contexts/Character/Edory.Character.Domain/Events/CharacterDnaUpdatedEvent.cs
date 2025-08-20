using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Charakter-DNA wurde aktualisiert
/// </summary>
public sealed record CharacterDnaUpdatedEvent(
    CharacterId CharacterId,
    CharacterDna OldDna,
    CharacterDna NewDna,
    FamilyId UpdatingFamilyId
) : DomainEvent;
