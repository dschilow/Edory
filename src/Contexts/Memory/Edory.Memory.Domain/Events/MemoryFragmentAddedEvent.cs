using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain.Events;

/// <summary>
/// Event: Memory-Fragment wurde hinzugefügt
/// </summary>
public sealed record MemoryFragmentAddedEvent(
    MemoryId MemoryId,
    Guid CharacterInstanceId,
    MemoryType Type,
    MemoryFragment Fragment
) : DomainEvent;
