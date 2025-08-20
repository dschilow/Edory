using System;

namespace Edory.SharedKernel.DomainObjects;

/// <summary>
/// Basis-Implementierung für Domain Events
/// </summary>
public abstract record DomainEvent : IDomainEvent
{
    public DateTime OccurredOn { get; } = DateTime.UtcNow;
    public Guid EventId { get; } = Guid.NewGuid();
}
