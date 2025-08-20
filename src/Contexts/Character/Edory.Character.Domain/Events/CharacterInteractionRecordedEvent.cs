using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain.Events;

/// <summary>
/// Event: Interaktion mit Charakter wurde aufgezeichnet
/// </summary>
public sealed record CharacterInteractionRecordedEvent(
    CharacterInstanceId InstanceId,
    CharacterId OriginalCharacterId,
    FamilyId OwnerFamilyId,
    DateTime InteractionTime
) : DomainEvent;
