using Microsoft.EntityFrameworkCore;
using Edory.Character.Domain;
using Edory.Character.Domain.Repositories;
using Edory.Infrastructure.Data;

namespace Edory.Infrastructure.Repositories;

/// <summary>
/// PostgreSQL Implementation des Character Repository
/// Verwaltet die Basis-Charaktere (Templates)
/// </summary>
public class CharacterRepository : ICharacterRepository
{
    private readonly EdoryDbContext _context;

    public CharacterRepository(EdoryDbContext context)
    {
        _context = context;
    }

    public async Task<Character.Domain.Character?> GetByIdAsync(CharacterId id, CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> GetPublicAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .Where(c => c.IsPublic)
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Gibt alle öffentlichen Charaktere zurück (Alias für GetPublicAsync)
    /// </summary>
    public async Task<IReadOnlyList<Character.Domain.Character>> GetPublicCharactersAsync(CancellationToken cancellationToken = default)
    {
        return await GetPublicAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> GetByCreatorAsync(FamilyId creatorFamilyId, CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .Where(c => c.CreatorFamilyId == creatorFamilyId)
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Gibt alle Charaktere einer Familie zurück (Alias für GetByCreatorAsync)
    /// </summary>
    public async Task<IReadOnlyList<Character.Domain.Character>> GetByCreatorFamilyAsync(FamilyId familyId, CancellationToken cancellationToken = default)
    {
        return await GetByCreatorAsync(familyId, cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> SearchByNameAsync(string searchTerm, CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .Where(c => c.Dna.Name.Contains(searchTerm) || c.Dna.Description.Contains(searchTerm))
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Sucht Charaktere nach Name oder Beschreibung
    /// </summary>
    public async Task<IReadOnlyList<Character.Domain.Character>> SearchAsync(string searchTerm, bool publicOnly = true, CancellationToken cancellationToken = default)
    {
        var query = _context.Characters.AsQueryable();
        
        if (publicOnly)
        {
            query = query.Where(c => c.IsPublic);
        }
        
        return await query
            .Where(c => c.Dna.Name.Contains(searchTerm) || c.Dna.Description.Contains(searchTerm))
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> GetByAgeRangeAsync(int minAge, int maxAge, CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .Where(c => c.Dna.MinAge <= maxAge && c.Dna.MaxAge >= minAge)
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Character.Domain.Character character, CancellationToken cancellationToken = default)
    {
        await _context.Characters.AddAsync(character, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Character.Domain.Character character, CancellationToken cancellationToken = default)
    {
        _context.Characters.Update(character);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(CharacterId id, CancellationToken cancellationToken = default)
    {
        var character = await GetByIdAsync(id, cancellationToken);
        if (character != null)
        {
            _context.Characters.Remove(character);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task IncrementAdoptionCountAsync(CharacterId id, CancellationToken cancellationToken = default)
    {
        var character = await GetByIdAsync(id, cancellationToken);
        if (character != null)
        {
            // Da AdoptionCount private ist, müssen wir es über die Domain-Methode erhöhen
            // Für jetzt verwenden wir einen direkten Update
            await _context.Database.ExecuteSqlRawAsync(
                "UPDATE \"Characters\" SET \"AdoptionCount\" = \"AdoptionCount\" + 1 WHERE \"Id\" = {0}",
                id.Value,
                cancellationToken);
        }
    }
}
