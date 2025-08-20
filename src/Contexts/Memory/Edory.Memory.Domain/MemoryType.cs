namespace Edory.Memory.Domain;

/// <summary>
/// Hierarchische Gedächtnistypen nach Wichtigkeit und Langlebigkeit
/// </summary>
public enum MemoryType
{
    /// <summary>
    /// Akut-Gedächtnis: Letzte 3-5 Geschichten, sehr detailliert
    /// </summary>
    Acute = 1,
    
    /// <summary>
    /// Thematisches Gedächtnis: Prägende Ereignisse und wichtige Erfahrungen
    /// </summary>
    Thematic = 2,
    
    /// <summary>
    /// Persönlichkeits-Gedächtnis: Kumulative Entwicklung und Kern-Eigenschaften
    /// </summary>
    Personality = 3
}
