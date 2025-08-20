using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain.Events;

/// <summary>
/// Event: Beschreibung des Lernziels wurde aktualisiert
/// </summary>
public sealed record LearningObjectiveDescriptionUpdatedEvent(
    LearningObjectiveId ObjectiveId,
    string OldDescription,
    string NewDescription
) : DomainEvent;
