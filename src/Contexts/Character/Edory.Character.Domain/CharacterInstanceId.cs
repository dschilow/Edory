using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Character.Domain;

/// <summary>
/// Strongly-typed Charakter-Instanz-ID
/// Jede Familie hat ihre eigene Instanz eines geteilten Charakters
/// </summary>
public sealed class CharacterInstanceId : ValueObject
{
    public Guid Value { get; }
    
    private CharacterInstanceId(Guid value)
    {
        Value = value;
    }
    
    public static CharacterInstanceId New() => new(Guid.NewGuid());
    
    public static CharacterInstanceId From(Guid value)
    {
        if (value == Guid.Empty)
            throw new ArgumentException("Charakter-Instanz-ID darf nicht leer sein", nameof(value));
            
        return new CharacterInstanceId(value);
    }
    
    public static implicit operator Guid(CharacterInstanceId instanceId) => instanceId.Value;
    public static implicit operator CharacterInstanceId(Guid value) => From(value);
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }
    
    public override string ToString() => Value.ToString();
}
