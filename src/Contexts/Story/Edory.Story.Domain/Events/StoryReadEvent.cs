using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Geschichte wurde gelesen
/// </summary>
public sealed record StoryReadEvent(
    StoryId StoryId,
    Guid CharacterInstanceId,
    Guid FamilyId,
    int TotalReadCount
) : DomainEvent;
