using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain;

/// <summary>
/// Strongly-typed Memory-ID
/// </summary>
public sealed class MemoryId : ValueObject
{
    public Guid Value { get; }
    
    private MemoryId(Guid value)
    {
        Value = value;
    }
    
    public static MemoryId New() => new(Guid.NewGuid());
    
    public static MemoryId From(Guid value)
    {
        if (value == Guid.Empty)
            throw new ArgumentException("Memory-ID darf nicht leer sein", nameof(value));
            
        return new MemoryId(value);
    }
    
    public static implicit operator Guid(MemoryId memoryId) => memoryId.Value;
    public static implicit operator MemoryId(Guid value) => From(value);
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }
    
    public override string ToString() => Value.ToString();
}
