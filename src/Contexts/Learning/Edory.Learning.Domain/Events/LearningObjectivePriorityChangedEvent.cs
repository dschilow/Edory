using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain.Events;

/// <summary>
/// Event: Priorität des Lernziels wurde geändert
/// </summary>
public sealed record LearningObjectivePriorityChangedEvent(
    LearningObjectiveId ObjectiveId,
    int OldPriority,
    int NewPriority
) : DomainEvent;
