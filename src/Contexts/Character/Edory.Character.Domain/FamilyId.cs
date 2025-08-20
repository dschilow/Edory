using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain;

/// <summary>
/// Strongly-typed Familien-ID
/// </summary>
public sealed class FamilyId : ValueObject
{
    public Guid Value { get; }
    
    private FamilyId(Guid value)
    {
        Value = value;
    }
    
    public static FamilyId New() => new(Guid.NewGuid());
    
    public static FamilyId From(Guid value)
    {
        if (value == Guid.Empty)
            throw new ArgumentException("Familien-ID darf nicht leer sein", nameof(value));
            
        return new FamilyId(value);
    }
    
    public static implicit operator Guid(FamilyId familyId) => familyId.Value;
    public static implicit operator FamilyId(Guid value) => From(value);
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }
    
    public override string ToString() => Value.ToString();
}
