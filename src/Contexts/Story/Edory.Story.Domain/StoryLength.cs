namespace Edory.Story.Domain;

/// <summary>
/// Länge einer Geschichte
/// </summary>
public enum StoryLength
{
    /// <summary>
    /// Kurz: 2-3 Minuten (300-500 Wörter)
    /// </summary>
    Short = 1,
    
    /// <summary>
    /// Mittel: 5-7 Minuten (600-900 Wörter)
    /// </summary>
    Medium = 2,
    
    /// <summary>
    /// Lang: 10-15 Minuten (1000-1500 Wörter)
    /// </summary>
    Long = 3,
    
    /// <summary>
    /// Fortsetzung: Mehrteilige Geschichte
    /// </summary>
    Series = 4
}
