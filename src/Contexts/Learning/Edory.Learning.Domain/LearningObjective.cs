using System;
using System.Collections.Generic;
using System.Linq;
using Edory.SharedKernel.DomainObjects;
using Edory.Learning.Domain.Events;

namespace Edory.Learning.Domain;

/// <summary>
/// Lernziel - Definiert was ein Kind lernen soll
/// </summary>
public sealed class LearningObjective : AggregateRoot<LearningObjectiveId>
{
    public string Title { get; private set; }
    public string Description { get; private set; }
    public LearningCategory Category { get; private set; }
    public SkillLevel Level { get; private set; }
    public int TargetAge { get; private set; }
    public int MinAge { get; private set; }
    public int MaxAge { get; private set; }
    public Guid FamilyId { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public bool IsActive { get; private set; }
    public int Priority { get; private set; } // 1-10, höher = wichtiger
    
    private readonly List<string> _keywords = new();
    public IReadOnlyList<string> Keywords => _keywords.AsReadOnly();
    
    private readonly List<string> _successCriteria = new();
    public IReadOnlyList<string> SuccessCriteria => _successCriteria.AsReadOnly();
    
    private LearningObjective(
        LearningObjectiveId id,
        string title,
        string description,
        LearningCategory category,
        SkillLevel level,
        int targetAge,
        int minAge,
        int maxAge,
        Guid familyId,
        int priority) : base(id)
    {
        Title = title;
        Description = description;
        Category = category;
        Level = level;
        TargetAge = targetAge;
        MinAge = minAge;
        MaxAge = maxAge;
        FamilyId = familyId;
        Priority = priority;
        CreatedAt = DateTime.UtcNow;
        IsActive = true;
        
        AddDomainEvent(new LearningObjectiveCreatedEvent(Id, title, category, familyId));
    }
    
    private LearningObjective() { } // Für EF Core
    
    /// <summary>
    /// Erstellt ein neues Lernziel
    /// </summary>
    public static LearningObjective Create(
        string title,
        string description,
        LearningCategory category,
        SkillLevel level,
        int targetAge,
        Guid familyId,
        int priority = 5)
    {
        ValidateInputs(title, description, targetAge, priority);
        
        var minAge = Math.Max(3, targetAge - 2);
        var maxAge = Math.Min(16, targetAge + 2);
        
        return new LearningObjective(
            LearningObjectiveId.New(),
            title,
            description,
            category,
            level,
            targetAge,
            minAge,
            maxAge,
            familyId,
            priority);
    }
    
    /// <summary>
    /// Fügt Schlüsselwörter hinzu, die in Geschichten eingebaut werden sollen
    /// </summary>
    public void AddKeywords(params string[] keywords)
    {
        foreach (var keyword in keywords.Where(k => !string.IsNullOrWhiteSpace(k)))
        {
            var cleanKeyword = keyword.Trim().ToLowerInvariant();
            if (!_keywords.Contains(cleanKeyword))
            {
                _keywords.Add(cleanKeyword);
            }
        }
        
        if (keywords.Any())
        {
            AddDomainEvent(new LearningObjectiveKeywordsAddedEvent(Id, keywords));
        }
    }
    
    /// <summary>
    /// Fügt Erfolgskriterien hinzu
    /// </summary>
    public void AddSuccessCriteria(params string[] criteria)
    {
        foreach (var criterion in criteria.Where(c => !string.IsNullOrWhiteSpace(c)))
        {
            var cleanCriterion = criterion.Trim();
            if (!_successCriteria.Contains(cleanCriterion))
            {
                _successCriteria.Add(cleanCriterion);
            }
        }
        
        if (criteria.Any())
        {
            AddDomainEvent(new LearningObjectiveSuccessCriteriaAddedEvent(Id, criteria));
        }
    }
    
    /// <summary>
    /// Aktualisiert die Priorität des Lernziels
    /// </summary>
    public void UpdatePriority(int newPriority)
    {
        if (newPriority < 1 || newPriority > 10)
            throw new ArgumentException("Priorität muss zwischen 1 und 10 liegen", nameof(newPriority));
        
        var oldPriority = Priority;
        Priority = newPriority;
        
        AddDomainEvent(new LearningObjectivePriorityChangedEvent(Id, oldPriority, newPriority));
    }
    
    /// <summary>
    /// Deaktiviert das Lernziel
    /// </summary>
    public void Deactivate()
    {
        if (!IsActive) return;
        
        IsActive = false;
        AddDomainEvent(new LearningObjectiveDeactivatedEvent(Id, FamilyId));
    }
    
    /// <summary>
    /// Aktiviert das Lernziel wieder
    /// </summary>
    public void Activate()
    {
        if (IsActive) return;
        
        IsActive = true;
        AddDomainEvent(new LearningObjectiveActivatedEvent(Id, FamilyId));
    }
    
    /// <summary>
    /// Aktualisiert die Beschreibung
    /// </summary>
    public void UpdateDescription(string newDescription)
    {
        if (string.IsNullOrWhiteSpace(newDescription))
            throw new ArgumentException("Beschreibung darf nicht leer sein", nameof(newDescription));
        
        if (newDescription.Length > 1000)
            throw new ArgumentException("Beschreibung darf maximal 1000 Zeichen lang sein", nameof(newDescription));
        
        var oldDescription = Description;
        Description = newDescription;
        
        AddDomainEvent(new LearningObjectiveDescriptionUpdatedEvent(Id, oldDescription, newDescription));
    }
    
    /// <summary>
    /// Prüft ob das Lernziel für ein bestimmtes Alter geeignet ist
    /// </summary>
    public bool IsAppropriateForAge(int age)
    {
        return age >= MinAge && age <= MaxAge;
    }
    
    /// <summary>
    /// Berechnet die Komplexität des Lernziels (1-10)
    /// </summary>
    public int GetComplexityScore()
    {
        var baseScore = (int)Level * 2; // 2, 4, 6, 8, 10
        var keywordBonus = Math.Min(2, _keywords.Count / 3); // Mehr Keywords = komplexer
        var criteriaBonus = Math.Min(2, _successCriteria.Count / 2); // Mehr Kriterien = komplexer
        
        return Math.Min(10, baseScore + keywordBonus + criteriaBonus);
    }
    
    /// <summary>
    /// Gibt eine Zusammenfassung für AI-Prompts zurück
    /// </summary>
    public string GetAiPromptSummary()
    {
        var summary = $"Lernziel: {Title}. {Description}";
        
        if (_keywords.Any())
        {
            summary += $" Schlüsselwörter: {string.Join(", ", _keywords)}.";
        }
        
        if (_successCriteria.Any())
        {
            summary += $" Erfolgskriterien: {string.Join("; ", _successCriteria)}.";
        }
        
        summary += $" Altersgruppe: {TargetAge} Jahre. Schwierigkeitsstufe: {Level}.";
        
        return summary;
    }
    
    private static void ValidateInputs(string title, string description, int targetAge, int priority)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Titel darf nicht leer sein", nameof(title));
        
        if (string.IsNullOrWhiteSpace(description))
            throw new ArgumentException("Beschreibung darf nicht leer sein", nameof(description));
        
        if (title.Length > 100)
            throw new ArgumentException("Titel darf maximal 100 Zeichen lang sein", nameof(title));
        
        if (description.Length > 1000)
            throw new ArgumentException("Beschreibung darf maximal 1000 Zeichen lang sein", nameof(description));
        
        if (targetAge < 3 || targetAge > 16)
            throw new ArgumentException("Zielgruppenalter muss zwischen 3 und 16 Jahren liegen", nameof(targetAge));
        
        if (priority < 1 || priority > 10)
            throw new ArgumentException("Priorität muss zwischen 1 und 10 liegen", nameof(priority));
    }
}
