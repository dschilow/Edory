using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Neue Charakter-Instanz wurde erstellt
/// </summary>
public sealed record CharacterInstanceCreatedEvent(
    CharacterInstanceId InstanceId,
    CharacterId OriginalCharacterId,
    FamilyId OwnerFamilyId,
    CharacterDna BaseDna
) : DomainEvent;
