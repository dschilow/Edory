namespace Edory.Memory.Domain.Repositories;

/// <summary>
/// Repository Interface für Charakter-Gedächtnis
/// Definiert alle notwendigen Datenbankoperationen für das Gedächtnissystem
/// </summary>
public interface ICharacterMemoryRepository
{
    /// <summary>
    /// Fügt ein neues CharacterMemory hinzu
    /// </summary>
    Task<CharacterMemory> AddAsync(CharacterMemory memory, CancellationToken cancellationToken = default);

    /// <summary>
    /// Holt CharacterMemory nach ID
    /// </summary>
    Task<CharacterMemory?> GetByIdAsync(MemoryId id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Holt alle Gedächtnisse einer CharacterInstance
    /// </summary>
    Task<IEnumerable<CharacterMemory>> GetByCharacterInstanceIdAsync(
        Guid characterInstanceId, 
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Holt ein spezifisches Gedächtnis nach CharacterInstance und Typ
    /// </summary>
    Task<CharacterMemory?> GetByCharacterInstanceAndTypeAsync(
        Guid characterInstanceId, 
        MemoryType type, 
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Aktualisiert ein existierendes CharacterMemory
    /// </summary>
    Task<CharacterMemory> UpdateAsync(CharacterMemory memory, CancellationToken cancellationToken = default);

    /// <summary>
    /// Löscht ein CharacterMemory
    /// </summary>
    Task DeleteAsync(CharacterMemory memory, CancellationToken cancellationToken = default);

    /// <summary>
    /// Sucht Gedächtnisse nach Inhalt und Tags
    /// </summary>
    Task<IEnumerable<CharacterMemory>> SearchAsync(
        Guid characterInstanceId,
        string query,
        string[]? tags = null,
        MemoryImportance? minImportance = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Holt alle Gedächtnisse die für Konsolidierung bereit sind
    /// </summary>
    Task<IEnumerable<CharacterMemory>> GetMemoriesForConsolidationAsync(
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Bereinigt alte Gedächtnisse
    /// </summary>
    Task CleanupOldMemoriesAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Erstellt oder holt alle drei Gedächtnistypen für eine CharacterInstance
    /// </summary>
    Task<IEnumerable<CharacterMemory>> GetOrCreateAllMemoryTypesAsync(
        Guid characterInstanceId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Führt Memory-Konsolidierung für eine CharacterInstance durch
    /// </summary>
    Task<bool> ConsolidateMemoriesAsync(
        Guid characterInstanceId,
        CancellationToken cancellationToken = default);
}