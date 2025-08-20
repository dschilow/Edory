using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain.Events;

/// <summary>
/// Event: Kapitel wurde zur Geschichte hinzugefügt
/// </summary>
public sealed record StoryChapterAddedEvent(
    StoryId StoryId,
    string ChapterTitle,
    int ChapterOrder
) : DomainEvent;
