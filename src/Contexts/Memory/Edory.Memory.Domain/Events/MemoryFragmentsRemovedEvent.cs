using System;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain.Events;

/// <summary>
/// Event: Memory-Fragmente wurden entfernt (wegen Kapazitätsbegrenzung)
/// </summary>
public sealed record MemoryFragmentsRemovedEvent(
    MemoryId MemoryId,
    Guid CharacterInstanceId,
    MemoryType Type,
    int RemovedCount
) : DomainEvent;
