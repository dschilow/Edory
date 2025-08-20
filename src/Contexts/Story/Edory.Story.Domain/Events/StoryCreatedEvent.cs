using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Neue Geschichte wurde erstellt
/// </summary>
public sealed record StoryCreatedEvent(
    StoryId StoryId,
    string Title,
    Guid CharacterInstanceId,
    Guid FamilyId,
    bool IsGenerated
) : DomainEvent;
