using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Geschichten-Inhalt wurde aktualisiert
/// </summary>
public sealed record StoryContentUpdatedEvent(
    StoryId StoryId,
    string OldContent,
    string NewContent
) : DomainEvent;
