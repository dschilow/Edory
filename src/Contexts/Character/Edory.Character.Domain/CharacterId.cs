using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain;

/// <summary>
/// Strongly-typed Charakter-ID
/// </summary>
public sealed class CharacterId : ValueObject
{
    public Guid Value { get; }
    
    private CharacterId(Guid value)
    {
        Value = value;
    }
    
    public static CharacterId New() => new(Guid.NewGuid());
    
    public static CharacterId From(Guid value)
    {
        if (value == Guid.Empty)
            throw new ArgumentException("Charakter-ID darf nicht leer sein", nameof(value));
            
        return new CharacterId(value);
    }
    
    public static implicit operator Guid(CharacterId characterId) => characterId.Value;
    public static implicit operator CharacterId(Guid value) => From(value);
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }
    
    public override string ToString() => Value.ToString();
}
