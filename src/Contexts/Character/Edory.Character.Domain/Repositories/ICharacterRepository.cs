using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Edory.Character.Domain.Repositories;

/// <summary>
/// Repository für Charakter-Aggregate
/// </summary>
public interface ICharacterRepository
{
    /// <summary>
    /// Findet einen Charakter nach ID
    /// </summary>
    Task<Character?> GetByIdAsync(CharacterId id, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gibt alle öffentlichen Charaktere zurück
    /// </summary>
    Task<IReadOnlyList<Character>> GetPublicCharactersAsync(CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gibt alle Charaktere einer Familie zurück
    /// </summary>
    Task<IReadOnlyList<Character>> GetByCreatorFamilyAsync(FamilyId familyId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Sucht Charaktere nach Name oder Beschreibung
    /// </summary>
    Task<IReadOnlyList<Character>> SearchAsync(string searchTerm, bool publicOnly = true, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Fügt einen neuen Charakter hinzu
    /// </summary>
    Task AddAsync(Character character, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Aktualisiert einen bestehenden Charakter
    /// </summary>
    Task UpdateAsync(Character character, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Löscht einen Charakter (nur wenn keine Instanzen existieren)
    /// </summary>
    Task DeleteAsync(CharacterId id, CancellationToken cancellationToken = default);
}
