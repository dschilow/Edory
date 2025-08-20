using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Charakter wurde öffentlich gemacht
/// </summary>
public sealed record CharacterMadePublicEvent(
    CharacterId CharacterId,
    FamilyId CreatorFamilyId
) : DomainEvent;
