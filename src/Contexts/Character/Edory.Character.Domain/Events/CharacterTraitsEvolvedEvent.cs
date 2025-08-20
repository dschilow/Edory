using Edory.SharedKernel.DomainObjects;
using Edory.SharedKernel.ValueObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Charakter-Eigenschaften haben sich entwickelt
/// </summary>
public sealed record CharacterTraitsEvolvedEvent(
    CharacterInstanceId InstanceId,
    CharacterId OriginalCharacterId,
    FamilyId OwnerFamilyId,
    CharacterTraits OldTraits,
    CharacterTraits NewTraits,
    int ExperienceCount
) : DomainEvent;
