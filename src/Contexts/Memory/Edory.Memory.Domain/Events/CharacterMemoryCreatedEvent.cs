using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain.Events;

/// <summary>
/// Event: Neues Charakter-Gedächtnis wurde erstellt
/// </summary>
public sealed record CharacterMemoryCreatedEvent(
    MemoryId MemoryId,
    Guid CharacterInstanceId,
    MemoryType Type
) : DomainEvent;
