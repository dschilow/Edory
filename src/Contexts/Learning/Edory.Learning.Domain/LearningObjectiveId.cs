using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Learning.Domain;

/// <summary>
/// Strongly-typed Lernziel-ID
/// </summary>
public sealed class LearningObjectiveId : ValueObject
{
    public Guid Value { get; }
    
    private LearningObjectiveId(Guid value)
    {
        Value = value;
    }
    
    public static LearningObjectiveId New() => new(Guid.NewGuid());
    
    public static LearningObjectiveId From(Guid value)
    {
        if (value == Guid.Empty)
            throw new ArgumentException("Lernziel-ID darf nicht leer sein", nameof(value));
            
        return new LearningObjectiveId(value);
    }
    
    public static implicit operator Guid(LearningObjectiveId objectiveId) => objectiveId.Value;
    public static implicit operator LearningObjectiveId(Guid value) => From(value);
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }
    
    public override string ToString() => Value.ToString();
}
