namespace Edory.SharedKernel.DomainObjects;

/// <summary>
/// Basis-Klasse für Aggregate Roots in Domain-Driven Design
/// </summary>
public abstract class AggregateRoot<TId> : Entity<TId>
    where TId : notnull
{
    protected AggregateRoot(TId id) : base(id) { }
    
    protected AggregateRoot() { } // Für EF Core
}
