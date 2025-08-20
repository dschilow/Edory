using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Like wurde von Geschichte entfernt
/// </summary>
public sealed record StoryUnlikedEvent(
    StoryId StoryId,
    Guid CharacterInstanceId,
    Guid FamilyId,
    int TotalLikes
) : DomainEvent;
