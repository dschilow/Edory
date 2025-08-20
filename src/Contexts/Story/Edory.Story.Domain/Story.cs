using System;
using System.Collections.Generic;
using System.Linq;
using Edory.SharedKernel.DomainObjects;
using Edory.Story.Domain.Events;

namespace Edory.Story.Domain;

/// <summary>
/// Geschichte Aggregate Root
/// </summary>
public sealed class Story : AggregateRoot<StoryId>
{
    public string Title { get; private set; }
    public string Content { get; private set; }
    public StoryConfiguration Configuration { get; private set; }
    public Guid CharacterInstanceId { get; private set; }
    public Guid FamilyId { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime? LastReadAt { get; private set; }
    public int ReadCount { get; private set; }
    public int LikesCount { get; private set; }
    public bool IsGenerated { get; private set; } // AI-generiert oder manuell erstellt
    public string? ImagePrompt { get; private set; } // Prompt für Bildgenerierung
    public string? ImageUrl { get; private set; } // URL des generierten Bildes
    public float Rating { get; private set; } // 1-5 Sterne
    public int RatingCount { get; private set; }
    
    private readonly List<string> _tags = new();
    public IReadOnlyList<string> Tags => _tags.AsReadOnly();
    
    private readonly List<StoryChapter> _chapters = new();
    public IReadOnlyList<StoryChapter> Chapters => _chapters.AsReadOnly();
    
    private Story(
        StoryId id,
        string title,
        string content,
        StoryConfiguration configuration,
        Guid characterInstanceId,
        Guid familyId,
        DateTime createdAt,
        bool isGenerated = true) : base(id)
    {
        Title = title;
        Content = content;
        Configuration = configuration;
        CharacterInstanceId = characterInstanceId;
        FamilyId = familyId;
        CreatedAt = createdAt;
        IsGenerated = isGenerated;
        ReadCount = 0;
        LikesCount = 0;
        Rating = 0;
        RatingCount = 0;
        
        AddDomainEvent(new StoryCreatedEvent(Id, title, characterInstanceId, familyId, isGenerated));
    }
    
    private Story() { } // Für EF Core
    
    /// <summary>
    /// Erstellt eine neue AI-generierte Geschichte
    /// </summary>
    public static Story CreateGenerated(
        string title,
        string content,
        StoryConfiguration configuration,
        Guid characterInstanceId,
        Guid familyId,
        string? imagePrompt = null)
    {
        ValidateStoryContent(title, content);
        
        var story = new Story(
            StoryId.New(),
            title,
            content,
            configuration,
            characterInstanceId,
            familyId,
            DateTime.UtcNow,
            isGenerated: true)
        {
            ImagePrompt = imagePrompt
        };
        
        return story;
    }
    
    /// <summary>
    /// Erstellt eine manuell verfasste Geschichte
    /// </summary>
    public static Story CreateManual(
        string title,
        string content,
        StoryConfiguration configuration,
        Guid characterInstanceId,
        Guid familyId)
    {
        ValidateStoryContent(title, content);
        
        return new Story(
            StoryId.New(),
            title,
            content,
            configuration,
            characterInstanceId,
            familyId,
            DateTime.UtcNow,
            isGenerated: false);
    }
    
    /// <summary>
    /// Fügt ein Kapitel hinzu (für mehrteilige Geschichten)
    /// </summary>
    public void AddChapter(string title, string content, int order)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Kapitel-Titel darf nicht leer sein", nameof(title));
        
        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("Kapitel-Inhalt darf nicht leer sein", nameof(content));
        
        var chapter = new StoryChapter(title, content, order);
        _chapters.Add(chapter);
        
        // Sortiere Kapitel nach Reihenfolge
        _chapters.Sort((a, b) => a.Order.CompareTo(b.Order));
        
        AddDomainEvent(new StoryChapterAddedEvent(Id, title, order));
    }
    
    /// <summary>
    /// Registriert das Lesen der Geschichte
    /// </summary>
    public void RecordReading()
    {
        ReadCount++;
        LastReadAt = DateTime.UtcNow;
        
        AddDomainEvent(new StoryReadEvent(Id, CharacterInstanceId, FamilyId, ReadCount));
    }
    
    /// <summary>
    /// Fügt ein "Like" hinzu
    /// </summary>
    public void AddLike()
    {
        LikesCount++;
        AddDomainEvent(new StoryLikedEvent(Id, CharacterInstanceId, FamilyId, LikesCount));
    }
    
    /// <summary>
    /// Entfernt ein "Like"
    /// </summary>
    public void RemoveLike()
    {
        if (LikesCount > 0)
        {
            LikesCount--;
            AddDomainEvent(new StoryUnlikedEvent(Id, CharacterInstanceId, FamilyId, LikesCount));
        }
    }
    
    /// <summary>
    /// Fügt eine Bewertung hinzu
    /// </summary>
    public void AddRating(float rating)
    {
        if (rating < 1 || rating > 5)
            throw new ArgumentException("Bewertung muss zwischen 1 und 5 Sternen liegen", nameof(rating));
        
        // Berechne neuen Durchschnitt
        var totalRating = (Rating * RatingCount) + rating;
        RatingCount++;
        Rating = totalRating / RatingCount;
        
        AddDomainEvent(new StoryRatedEvent(Id, CharacterInstanceId, FamilyId, rating, Rating));
    }
    
    /// <summary>
    /// Setzt die URL des generierten Bildes
    /// </summary>
    public void SetImageUrl(string imageUrl)
    {
        if (string.IsNullOrWhiteSpace(imageUrl))
            throw new ArgumentException("Bild-URL darf nicht leer sein", nameof(imageUrl));
        
        ImageUrl = imageUrl;
        AddDomainEvent(new StoryImageGeneratedEvent(Id, imageUrl));
    }
    
    /// <summary>
    /// Fügt Tags hinzu
    /// </summary>
    public void AddTags(params string[] tags)
    {
        foreach (var tag in tags.Where(t => !string.IsNullOrWhiteSpace(t)))
        {
            var cleanTag = tag.Trim().ToLowerInvariant();
            if (!_tags.Contains(cleanTag))
            {
                _tags.Add(cleanTag);
            }
        }
    }
    
    /// <summary>
    /// Aktualisiert den Inhalt der Geschichte
    /// </summary>
    public void UpdateContent(string newContent)
    {
        if (string.IsNullOrWhiteSpace(newContent))
            throw new ArgumentException("Geschichten-Inhalt darf nicht leer sein", nameof(newContent));
        
        if (newContent.Length > 10000)
            throw new ArgumentException("Geschichten-Inhalt darf maximal 10.000 Zeichen lang sein", nameof(newContent));
        
        var oldContent = Content;
        Content = newContent;
        
        AddDomainEvent(new StoryContentUpdatedEvent(Id, oldContent, newContent));
    }
    
    /// <summary>
    /// Berechnet die geschätzte Lesezeit in Minuten
    /// </summary>
    public int GetEstimatedReadingTime()
    {
        var wordCount = Content.Split(' ', StringSplitOptions.RemoveEmptyEntries).Length;
        return Math.Max(1, wordCount / 125); // Durchschnittlich 125 Wörter pro Minute
    }
    
    /// <summary>
    /// Prüft ob die Geschichte für eine bestimmte Altersgruppe geeignet ist
    /// </summary>
    public bool IsAppropriateForAge(int age)
    {
        return age >= Configuration.TargetAge - 1 && age <= Configuration.TargetAge + 3;
    }
    
    private static void ValidateStoryContent(string title, string content)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Geschichten-Titel darf nicht leer sein", nameof(title));
        
        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("Geschichten-Inhalt darf nicht leer sein", nameof(content));
        
        if (title.Length > 100)
            throw new ArgumentException("Geschichten-Titel darf maximal 100 Zeichen lang sein", nameof(title));
        
        if (content.Length > 10000)
            throw new ArgumentException("Geschichten-Inhalt darf maximal 10.000 Zeichen lang sein", nameof(content));
    }
}

/// <summary>
/// Kapitel einer mehrteiligen Geschichte
/// </summary>
public sealed class StoryChapter
{
    public string Title { get; }
    public string Content { get; }
    public int Order { get; }
    public DateTime CreatedAt { get; }
    
    internal StoryChapter(string title, string content, int order)
    {
        Title = title;
        Content = content;
        Order = order;
        CreatedAt = DateTime.UtcNow;
    }
}
