using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Geschichte wurde geliked
/// </summary>
public sealed record StoryLikedEvent(
    StoryId StoryId,
    Guid CharacterInstanceId,
    Guid FamilyId,
    int TotalLikes
) : DomainEvent;
