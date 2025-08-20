using System;
using System.Collections.Generic;
using System.Linq;
using Edory.SharedKernel.DomainObjects;
using Edory.Memory.Domain.Events;

namespace Edory.Memory.Domain;

/// <summary>
/// Charakter-Gedächtnis Aggregate Root
/// Verwaltet das hierarchische Gedächtnissystem eines Charakters
/// </summary>
public sealed class CharacterMemory : AggregateRoot<MemoryId>
{
    public Guid CharacterInstanceId { get; private set; }
    public MemoryType Type { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime LastUpdatedAt { get; private set; }
    
    private readonly List<MemoryFragment> _fragments = new();
    public IReadOnlyList<MemoryFragment> Fragments => _fragments.AsReadOnly();
    
    // Konfiguration für verschiedene Gedächtnistypen
    public int MaxFragments => Type switch
    {
        MemoryType.Acute => 50,      // Detailliert, aber begrenzt
        MemoryType.Thematic => 100,  // Mittlere Kapazität
        MemoryType.Personality => 25 // Wenige, aber wichtige Erinnerungen
    };
    
    public TimeSpan RetentionPeriod => Type switch
    {
        MemoryType.Acute => TimeSpan.FromDays(30),
        MemoryType.Thematic => TimeSpan.FromDays(365),
        MemoryType.Personality => TimeSpan.MaxValue // Permanent
    };
    
    private CharacterMemory(
        MemoryId id,
        Guid characterInstanceId,
        MemoryType type,
        DateTime createdAt) : base(id)
    {
        CharacterInstanceId = characterInstanceId;
        Type = type;
        CreatedAt = createdAt;
        LastUpdatedAt = createdAt;
        
        AddDomainEvent(new CharacterMemoryCreatedEvent(Id, characterInstanceId, type));
    }
    
    private CharacterMemory() { } // Für EF Core
    
    /// <summary>
    /// Erstellt ein neues Charakter-Gedächtnis
    /// </summary>
    public static CharacterMemory Create(
        Guid characterInstanceId,
        MemoryType type)
    {
        return new CharacterMemory(
            MemoryId.New(),
            characterInstanceId,
            type,
            DateTime.UtcNow);
    }
    
    /// <summary>
    /// Fügt ein neues Memory-Fragment hinzu
    /// </summary>
    public void AddFragment(MemoryFragment fragment)
    {
        if (fragment == null)
            throw new ArgumentNullException(nameof(fragment));
        
        // Prüfe Kapazitätsbegrenzung
        if (_fragments.Count >= MaxFragments)
        {
            // Entferne die ältesten, unwichtigsten Fragmente
            RemoveOldestFragments();
        }
        
        _fragments.Add(fragment);
        LastUpdatedAt = DateTime.UtcNow;
        
        AddDomainEvent(new MemoryFragmentAddedEvent(
            Id, CharacterInstanceId, Type, fragment));
    }
    
    /// <summary>
    /// Fügt mehrere Fragmente gleichzeitig hinzu
    /// </summary>
    public void AddFragments(IEnumerable<MemoryFragment> fragments)
    {
        foreach (var fragment in fragments)
        {
            AddFragment(fragment);
        }
    }
    
    /// <summary>
    /// Konsolidiert Erinnerungen in eine höhere Gedächtnisebene
    /// </summary>
    public IEnumerable<MemoryFragment> ConsolidateMemories()
    {
        if (Type == MemoryType.Personality)
            return Enumerable.Empty<MemoryFragment>(); // Höchste Ebene
        
        var candidatesForConsolidation = _fragments
            .Where(f => f.GetConsolidationProbability() > 70)
            .OrderByDescending(f => f.GetConsolidationProbability())
            .Take(5) // Maximal 5 pro Konsolidierung
            .ToList();
        
        if (candidatesForConsolidation.Any())
        {
            // Entferne konsolidierte Fragmente aus dieser Ebene
            foreach (var fragment in candidatesForConsolidation)
            {
                _fragments.Remove(fragment);
            }
            
            LastUpdatedAt = DateTime.UtcNow;
            
            AddDomainEvent(new MemoryConsolidatedEvent(
                Id, CharacterInstanceId, Type, candidatesForConsolidation));
        }
        
        return candidatesForConsolidation;
    }
    
    /// <summary>
    /// Sucht nach relevanten Erinnerungen basierend auf Tags oder Inhalt
    /// </summary>
    public IEnumerable<MemoryFragment> SearchMemories(
        string query,
        string[]? tags = null,
        MemoryImportance? minImportance = null)
    {
        var queryWords = query.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries);
        
        return _fragments.Where(fragment =>
        {
            // Textsuche
            var contentMatch = queryWords.Any(word => 
                fragment.Content.ToLowerInvariant().Contains(word));
            
            // Tag-Suche
            var tagMatch = tags?.Any(tag => 
                fragment.Tags.Contains(tag, StringComparer.OrdinalIgnoreCase)) ?? true;
            
            // Wichtigkeitsfilter
            var importanceMatch = minImportance == null || fragment.Importance >= minImportance;
            
            return contentMatch && tagMatch && importanceMatch;
        })
        .OrderByDescending(f => f.Importance)
        .ThenByDescending(f => f.Timestamp);
    }
    
    /// <summary>
    /// Holt Erinnerungen nach Typ
    /// </summary>
    public IEnumerable<MemoryFragment> GetMemoriesByType(MemoryType memoryType)
    {
        return _fragments.Where(f => f.Type == memoryType);
    }
    
    /// <summary>
    /// Holt alle Erinnerungen
    /// </summary>
    public IEnumerable<MemoryFragment> GetAllMemories()
    {
        return _fragments.AsReadOnly();
    }
    
    /// <summary>
    /// Deaktiviert ein Memory-Fragment
    /// </summary>
    public void DeactivateMemory(Guid fragmentId)
    {
        var fragment = _fragments.FirstOrDefault(f => f.Id == fragmentId);
        if (fragment != null)
        {
            fragment.Deactivate();
            LastUpdatedAt = DateTime.UtcNow;
        }
    }
    
    /// <summary>
    /// Fügt ein Memory-Fragment hinzu (Alias für AddFragment)
    /// </summary>
    public void AddMemoryFragment(MemoryFragment fragment)
    {
        AddFragment(fragment);
    }
    
    /// <summary>
    /// Entfernt ein Memory-Fragment
    /// </summary>
    public void RemoveMemoryFragment(Guid fragmentId)
    {
        var fragment = _fragments.FirstOrDefault(f => f.Id == fragmentId);
        if (fragment != null)
        {
            _fragments.Remove(fragment);
            LastUpdatedAt = DateTime.UtcNow;
        }
    }

    /// <summary>
    /// Bereinigt veraltete Erinnerungen
    /// </summary>
    public void CleanupOldMemories()
    {
        if (Type == MemoryType.Personality)
            return; // Persönlichkeits-Erinnerungen werden nicht gelöscht
        
        var cutoffDate = DateTime.UtcNow - RetentionPeriod;
        var oldFragments = _fragments
            .Where(f => f.Timestamp < cutoffDate && f.Importance < MemoryImportance.High)
            .ToList();
        
        foreach (var fragment in oldFragments)
        {
            _fragments.Remove(fragment);
        }
        
        if (oldFragments.Any())
        {
            LastUpdatedAt = DateTime.UtcNow;
            AddDomainEvent(new OldMemoriesCleanedUpEvent(
                Id, CharacterInstanceId, Type, oldFragments.Count));
        }
    }
    
    /// <summary>
    /// Gibt die emotionale Zusammenfassung der Erinnerungen zurück
    /// </summary>
    public EmotionalContext GetEmotionalSummary()
    {
        if (!_fragments.Any())
            return EmotionalContext.Neutral;
        
        var avgJoy = (int)_fragments.Average(f => f.EmotionalContext.Joy);
        var avgSadness = (int)_fragments.Average(f => f.EmotionalContext.Sadness);
        var avgFear = (int)_fragments.Average(f => f.EmotionalContext.Fear);
        var avgAnger = (int)_fragments.Average(f => f.EmotionalContext.Anger);
        var avgSurprise = (int)_fragments.Average(f => f.EmotionalContext.Surprise);
        var avgPride = (int)_fragments.Average(f => f.EmotionalContext.Pride);
        var avgExcitement = (int)_fragments.Average(f => f.EmotionalContext.Excitement);
        var avgCalmness = (int)_fragments.Average(f => f.EmotionalContext.Calmness);
        
        return EmotionalContext.Create(
            avgJoy, avgSadness, avgFear, avgAnger,
            avgSurprise, avgPride, avgExcitement, avgCalmness);
    }
    
    private void RemoveOldestFragments()
    {
        // Entferne die ältesten Fragmente mit niedriger Wichtigkeit
        var toRemove = _fragments
            .Where(f => f.Importance <= MemoryImportance.Normal)
            .OrderBy(f => f.Timestamp)
            .Take(5)
            .ToList();
        
        if (toRemove.Count < 5)
        {
            // Falls nicht genug unwichtige Fragmente, entferne einfach die ältesten
            toRemove = _fragments
                .OrderBy(f => f.Timestamp)
                .Take(5)
                .ToList();
        }
        
        foreach (var fragment in toRemove)
        {
            _fragments.Remove(fragment);
        }
        
        if (toRemove.Any())
        {
            AddDomainEvent(new MemoryFragmentsRemovedEvent(
                Id, CharacterInstanceId, Type, toRemove.Count));
        }
    }
}
