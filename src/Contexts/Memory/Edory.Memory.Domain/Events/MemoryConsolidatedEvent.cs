using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain.Events;

/// <summary>
/// Event: Erinnerungen wurden konsolidiert (in höhere Ebene verschoben)
/// </summary>
public sealed record MemoryConsolidatedEvent(
    MemoryId MemoryId,
    Guid CharacterInstanceId,
    MemoryType FromType,
    IReadOnlyList<MemoryFragment> ConsolidatedFragments
) : DomainEvent;
