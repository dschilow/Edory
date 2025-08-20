using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Geschichte wurde bewertet
/// </summary>
public sealed record StoryRatedEvent(
    StoryId StoryId,
    Guid CharacterInstanceId,
    Guid FamilyId,
    float NewRating,
    float AverageRating
) : DomainEvent;
