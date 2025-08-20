using System;
using System.Collections.Generic;
using Edory.SharedKernel.DomainObjects;

namespace Edory.Memory.Domain;

/// <summary>
/// Ein Fragment einer Erinnerung - kleine, spezifische Details
/// </summary>
public sealed class MemoryFragment : Entity<Guid>
{
    public string Content { get; private set; }
    public string[] Tags { get; private set; }
    public MemoryImportance Importance { get; private set; }
    public EmotionalContext EmotionalContext { get; private set; }
    public DateTime Timestamp { get; private set; }
    public MemoryType Type { get; private set; }
    public bool IsActive { get; private set; } = true;
    
    private MemoryFragment(
        Guid id,
        string content,
        string[] tags,
        MemoryImportance importance,
        EmotionalContext emotionalContext,
        DateTime timestamp,
        MemoryType type) : base(id)
    {
        Content = content;
        Tags = tags;
        Importance = importance;
        EmotionalContext = emotionalContext;
        Timestamp = timestamp;
        Type = type;
    }
    
    private MemoryFragment() { } // For EF Core
    
    public static MemoryFragment Create(
        string content,
        string[] tags,
        MemoryType type,
        MemoryImportance importance = MemoryImportance.Normal,
        EmotionalContext? emotionalContext = null,
        DateTime? timestamp = null)
    {
        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("Memory-Fragment-Content darf nicht leer sein", nameof(content));
        
        if (content.Length > 500)
            throw new ArgumentException("Memory-Fragment darf maximal 500 Zeichen lang sein", nameof(content));
        
        return new MemoryFragment(
            Guid.NewGuid(),
            content.Trim(),
            tags ?? Array.Empty<string>(),
            importance,
            emotionalContext ?? EmotionalContext.Neutral,
            timestamp ?? DateTime.UtcNow,
            type);
    }
    
    public static MemoryFragment CreateThematic(
        string content,
        string[] tags,
        MemoryImportance importance = MemoryImportance.Normal,
        EmotionalContext? emotionalContext = null)
    {
        return Create(content, tags, MemoryType.Thematic, importance, emotionalContext);
    }
    
    public static MemoryFragment CreatePersonality(
        string content,
        string[] tags,
        MemoryImportance importance = MemoryImportance.High,
        EmotionalContext? emotionalContext = null)
    {
        return Create(content, tags, MemoryType.Personality, importance, emotionalContext);
    }
    
    public void Deactivate()
    {
        IsActive = false;
    }
    
    /// <summary>
    /// Berechnet die Wahrscheinlichkeit der Konsolidierung (0-100)
    /// </summary>
    public int GetConsolidationProbability()
    {
        var baseScore = (int)Importance * 20; // 20, 40, 60, 80
        var emotionalBonus = EmotionalContext.GetIntensity() / 5; // 0-20
        var ageDecay = Math.Max(0, 10 - (DateTime.UtcNow - Timestamp).Days); // Newer = better
        
        return Math.Min(100, baseScore + emotionalBonus + ageDecay);
    }
    

}
