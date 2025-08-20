using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain.Events;

/// <summary>
/// Event: Erfolgskriterien wurden zu Lernziel hinzugefügt
/// </summary>
public sealed record LearningObjectiveSuccessCriteriaAddedEvent(
    LearningObjectiveId ObjectiveId,
    string[] SuccessCriteria
) : DomainEvent;
