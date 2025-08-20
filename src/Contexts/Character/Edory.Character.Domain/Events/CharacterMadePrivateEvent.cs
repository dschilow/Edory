using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Charakter wurde wieder privat gemacht
/// </summary>
public sealed record CharacterMadePrivateEvent(
    CharacterId CharacterId,
    FamilyId CreatorFamilyId
) : DomainEvent;
