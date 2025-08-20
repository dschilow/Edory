using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain.Events;

/// <summary>
/// Event: Schlüsselwörter wurden zu Lernziel hinzugefügt
/// </summary>
public sealed record LearningObjectiveKeywordsAddedEvent(
    LearningObjectiveId ObjectiveId,
    string[] Keywords
) : DomainEvent;
