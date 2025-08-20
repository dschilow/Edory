using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Story.Domain;

/// <summary>
/// Strongly-typed Story-ID
/// </summary>
public sealed class StoryId : ValueObject
{
    public Guid Value { get; }
    
    private StoryId(Guid value)
    {
        Value = value;
    }
    
    public static StoryId New() => new(Guid.NewGuid());
    
    public static StoryId From(Guid value)
    {
        if (value == Guid.Empty)
            throw new ArgumentException("Story-ID darf nicht leer sein", nameof(value));
            
        return new StoryId(value);
    }
    
    public static implicit operator Guid(StoryId storyId) => storyId.Value;
    public static implicit operator StoryId(Guid value) => From(value);
    
    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }
    
    public override string ToString() => Value.ToString();
}
