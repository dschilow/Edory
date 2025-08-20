using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain.Events;

/// <summary>
/// Event: Lernziel wurde deaktiviert
/// </summary>
public sealed record LearningObjectiveDeactivatedEvent(
    LearningObjectiveId ObjectiveId,
    Guid FamilyId
) : DomainEvent;
