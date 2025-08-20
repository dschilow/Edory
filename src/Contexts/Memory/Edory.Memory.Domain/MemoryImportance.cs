namespace Edory.Memory.Domain;

/// <summary>
/// Wichtigkeitsstufen für Erinnerungen
/// Bestimmt die Wahrscheinlichkeit der Konsolidierung in höhere Gedächtnisebenen
/// </summary>
public enum MemoryImportance
{
    /// <summary>
    /// Niedrig: Alltägliche Ereignisse, wahrscheinlich vergessen
    /// </summary>
    Low = 1,
    
    /// <summary>
    /// Normal: Interessante Ereignisse, möglicherweise erinnert
    /// </summary>
    Normal = 2,
    
    /// <summary>
    /// Hoch: Bedeutsame Ereignisse, wahrscheinlich erinnert
    /// </summary>
    High = 3,
    
    /// <summary>
    /// Kritisch: Lebensverändernde Ereignisse, definitiv erinnert
    /// </summary>
    Critical = 4
}
