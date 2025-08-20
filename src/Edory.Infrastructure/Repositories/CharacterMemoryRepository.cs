using Microsoft.EntityFrameworkCore;
using Edory.Infrastructure.Data;
using Edory.Memory.Domain;
using Edory.Memory.Domain.Repositories;

namespace Edory.Infrastructure.Repositories;

/// <summary>
/// PostgreSQL Repository für Charakter-Gedächtnis
/// Implementiert das vollständige hierarchische Gedächtnissystem
/// </summary>
public class CharacterMemoryRepository : ICharacterMemoryRepository
{
    private readonly EdoryDbContext _context;

    public CharacterMemoryRepository(EdoryDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Fügt ein neues CharacterMemory hinzu
    /// </summary>
    public async Task<CharacterMemory> AddAsync(CharacterMemory memory, CancellationToken cancellationToken = default)
    {
        var entity = await _context.CharacterMemories.AddAsync(memory, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return entity.Entity;
    }

    /// <summary>
    /// Holt CharacterMemory nach ID
    /// </summary>
    public async Task<CharacterMemory?> GetByIdAsync(MemoryId id, CancellationToken cancellationToken = default)
    {
        return await _context.CharacterMemories
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);
    }

    /// <summary>
    /// Holt alle Gedächtnisse einer CharacterInstance
    /// </summary>
    public async Task<IEnumerable<CharacterMemory>> GetByCharacterInstanceIdAsync(
        Guid characterInstanceId, 
        CancellationToken cancellationToken = default)
    {
        return await _context.CharacterMemories
            .Where(m => m.CharacterInstanceId == characterInstanceId)
            .OrderBy(m => m.Type) // Acute, Thematic, Personality
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Holt ein spezifisches Gedächtnis nach CharacterInstance und Typ
    /// </summary>
    public async Task<CharacterMemory?> GetByCharacterInstanceAndTypeAsync(
        Guid characterInstanceId, 
        MemoryType type, 
        CancellationToken cancellationToken = default)
    {
        return await _context.CharacterMemories
            .FirstOrDefaultAsync(m => m.CharacterInstanceId == characterInstanceId && m.Type == type, cancellationToken);
    }

    /// <summary>
    /// Aktualisiert ein existierendes CharacterMemory
    /// </summary>
    public async Task<CharacterMemory> UpdateAsync(CharacterMemory memory, CancellationToken cancellationToken = default)
    {
        _context.CharacterMemories.Update(memory);
        await _context.SaveChangesAsync(cancellationToken);
        return memory;
    }

    /// <summary>
    /// Löscht ein CharacterMemory
    /// </summary>
    public async Task DeleteAsync(CharacterMemory memory, CancellationToken cancellationToken = default)
    {
        _context.CharacterMemories.Remove(memory);
        await _context.SaveChangesAsync(cancellationToken);
    }

    /// <summary>
    /// Sucht Gedächtnisse nach Inhalt und Tags
    /// </summary>
    public async Task<IEnumerable<CharacterMemory>> SearchAsync(
        Guid characterInstanceId,
        string query,
        string[]? tags = null,
        MemoryImportance? minImportance = null,
        CancellationToken cancellationToken = default)
    {
        var queryWords = query.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries);

        var memories = await _context.CharacterMemories
            .Where(m => m.CharacterInstanceId == characterInstanceId)
            .ToListAsync(cancellationToken);

        // In-Memory-Filterung für komplexe Fragment-Suche
        return memories.Where(memory =>
            memory.Fragments.Any(fragment =>
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
            }));
    }

    /// <summary>
    /// Holt alle Gedächtnisse die für Konsolidierung bereit sind
    /// </summary>
    public async Task<IEnumerable<CharacterMemory>> GetMemoriesForConsolidationAsync(
        CancellationToken cancellationToken = default)
    {
        var cutoffDate = DateTime.UtcNow.AddDays(-7); // Memories älter als eine Woche

        return await _context.CharacterMemories
            .Where(m => m.Type != MemoryType.Personality && // Personality-Memories werden nicht konsolidiert
                       m.LastUpdatedAt < cutoffDate)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Bereinigt alte Gedächtnisse
    /// </summary>
    public async Task CleanupOldMemoriesAsync(CancellationToken cancellationToken = default)
    {
        var memories = await _context.CharacterMemories
            .Where(m => m.Type != MemoryType.Personality)
            .ToListAsync(cancellationToken);

        foreach (var memory in memories)
        {
            memory.CleanupOldMemories();
        }

        await _context.SaveChangesAsync(cancellationToken);
    }

    /// <summary>
    /// Erstellt oder holt alle drei Gedächtnistypen für eine CharacterInstance
    /// </summary>
    public async Task<IEnumerable<CharacterMemory>> GetOrCreateAllMemoryTypesAsync(
        Guid characterInstanceId,
        CancellationToken cancellationToken = default)
    {
        var existingMemories = await GetByCharacterInstanceIdAsync(characterInstanceId, cancellationToken);
        var existingTypes = existingMemories.Select(m => m.Type).ToHashSet();

        var allTypes = new[] { MemoryType.Acute, MemoryType.Thematic, MemoryType.Personality };
        var memories = existingMemories.ToList();

        foreach (var type in allTypes)
        {
            if (!existingTypes.Contains(type))
            {
                var newMemory = CharacterMemory.Create(characterInstanceId, type);
                memories.Add(await AddAsync(newMemory, cancellationToken));
            }
        }

        return memories;
    }

    /// <summary>
    /// Führt Memory-Konsolidierung für eine CharacterInstance durch
    /// </summary>
    public async Task<bool> ConsolidateMemoriesAsync(
        Guid characterInstanceId,
        CancellationToken cancellationToken = default)
    {
        var memories = await GetByCharacterInstanceIdAsync(characterInstanceId, cancellationToken);
        var memoriesByType = memories.ToDictionary(m => m.Type, m => m);

        var hasConsolidated = false;

        // Konsolidiere Acute -> Thematic
        if (memoriesByType.TryGetValue(MemoryType.Acute, out var acuteMemory) &&
            memoriesByType.TryGetValue(MemoryType.Thematic, out var thematicMemory))
        {
            var consolidatedFragments = acuteMemory.ConsolidateMemories();
            if (consolidatedFragments.Any())
            {
                thematicMemory.AddFragments(consolidatedFragments);
                hasConsolidated = true;
            }
        }

        // Konsolidiere Thematic -> Personality
        if (memoriesByType.TryGetValue(MemoryType.Thematic, out var thematicMem) &&
            memoriesByType.TryGetValue(MemoryType.Personality, out var personalityMemory))
        {
            var consolidatedFragments = thematicMem.ConsolidateMemories();
            if (consolidatedFragments.Any())
            {
                personalityMemory.AddFragments(consolidatedFragments);
                hasConsolidated = true;
            }
        }

        if (hasConsolidated)
        {
            await _context.SaveChangesAsync(cancellationToken);
        }

        return hasConsolidated;
    }
}

