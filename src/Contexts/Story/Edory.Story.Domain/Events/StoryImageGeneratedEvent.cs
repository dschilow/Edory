using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Bild für Geschichte wurde generiert
/// </summary>
public sealed record StoryImageGeneratedEvent(
    StoryId StoryId,
    string ImageUrl
) : DomainEvent;
