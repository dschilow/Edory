using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain.Events;

/// <summary>
/// Event: Neues Lernziel wurde erstellt
/// </summary>
public sealed record LearningObjectiveCreatedEvent(
    LearningObjectiveId ObjectiveId,
    string Title,
    LearningCategory Category,
    Guid FamilyId
) : DomainEvent;
