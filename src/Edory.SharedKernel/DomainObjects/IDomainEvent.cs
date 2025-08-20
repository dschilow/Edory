using System;

namespace Edory.SharedKernel.DomainObjects;

/// <summary>
/// Marker-Interface für alle Domain Events
/// </summary>
public interface IDomainEvent
{
    /// <summary>
    /// Zeitpunkt, wann das Event aufgetreten ist
    /// </summary>
    DateTime OccurredOn { get; }
    
    /// <summary>
    /// Eindeutige ID des Events
    /// </summary>
    Guid EventId { get; }
}
