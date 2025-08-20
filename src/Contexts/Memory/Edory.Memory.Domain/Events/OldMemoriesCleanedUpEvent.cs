using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain.Events;

/// <summary>
/// Event: Alte Erinnerungen wurden bereinigt
/// </summary>
public sealed record OldMemoriesCleanedUpEvent(
    MemoryId MemoryId,
    Guid CharacterInstanceId,
    MemoryType Type,
    int RemovedCount
) : DomainEvent;
