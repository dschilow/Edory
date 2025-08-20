using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Charakter-Instanz wurde umbenannt
/// </summary>
public sealed record CharacterInstanceRenamedEvent(
    CharacterInstanceId InstanceId,
    CharacterId OriginalCharacterId,
    FamilyId OwnerFamilyId,
    string? OldName,
    string? NewName
) : DomainEvent;
