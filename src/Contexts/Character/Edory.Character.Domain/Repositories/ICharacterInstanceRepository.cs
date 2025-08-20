using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Edory.Character.Domain.Repositories;

/// <summary>
/// Repository für Charakter-Instanzen
/// </summary>
public interface ICharacterInstanceRepository
{
    /// <summary>
    /// Findet eine Charakter-Instanz nach ID
    /// </summary>
    Task<CharacterInstance?> GetByIdAsync(CharacterInstanceId id, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gibt alle Charakter-Instanzen einer Familie zurück
    /// </summary>
    Task<IReadOnlyList<CharacterInstance>> GetByFamilyAsync(FamilyId familyId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gibt alle Instanzen eines bestimmten Charakters zurück
    /// </summary>
    Task<IReadOnlyList<CharacterInstance>> GetByOriginalCharacterAsync(CharacterId originalCharacterId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Findet eine spezifische Instanz eines Charakters in einer Familie
    /// </summary>
    Task<CharacterInstance?> GetByCharacterAndFamilyAsync(CharacterId characterId, FamilyId familyId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gibt die aktivsten Charakter-Instanzen zurück (nach letzter Interaktion)
    /// </summary>
    Task<IReadOnlyList<CharacterInstance>> GetMostActiveAsync(FamilyId familyId, int count = 10, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Fügt eine neue Charakter-Instanz hinzu
    /// </summary>
    Task AddAsync(CharacterInstance instance, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Aktualisiert eine bestehende Charakter-Instanz
    /// </summary>
    Task UpdateAsync(CharacterInstance instance, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Löscht eine Charakter-Instanz
    /// </summary>
    Task DeleteAsync(CharacterInstanceId id, CancellationToken cancellationToken = default);
}
