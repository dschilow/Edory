using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain.Events;

/// <summary>
/// Event: Lernziel wurde aktiviert
/// </summary>
public sealed record LearningObjectiveActivatedEvent(
    LearningObjectiveId ObjectiveId,
    Guid FamilyId
) : DomainEvent;
