using Microsoft.EntityFrameworkCore;
using Edory.Character.Domain;
using Edory.Character.Domain.Repositories;
using Edory.Infrastructure.Data;

namespace Edory.Infrastructure.Repositories;

/// <summary>
/// PostgreSQL Implementation des Character Repository
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

    public async Task<IReadOnlyList<Character.Domain.Character>> GetPublicCharactersAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .Where(c => c.IsPublic)
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> GetByIdsAsync(
        IEnumerable<CharacterId> ids, 
        CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .Where(c => ids.Contains(c.Id))
            .ToListAsync(cancellationToken);
    }

    public async Task<Character.Domain.Character?> GetByNameAsync(string name, CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .FirstOrDefaultAsync(c => c.Dna.Name == name, cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> GetByCreatorFamilyAsync(FamilyId familyId, CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .Where(c => c.CreatorFamilyId == familyId)
            .OrderBy(c => c.Dna.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Character.Domain.Character>> SearchAsync(
        string searchTerm, 
        bool publicOnly = true, 
        CancellationToken cancellationToken = default)
    {
        var query = _context.Characters.AsQueryable();
        
        if (publicOnly)
        {
            query = query.Where(c => c.IsPublic);
        }
        
        return await query
            .Where(c => c.Dna.Name.Contains(searchTerm) || 
                       c.Dna.Description.Contains(searchTerm))
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
            // Character kann nur gelöscht werden wenn keine Instanzen existieren
            var hasInstances = await _context.CharacterInstances
                .AnyAsync(ci => ci.OriginalCharacterId == id, cancellationToken);
            
            if (hasInstances)
                throw new InvalidOperationException("Character cannot be deleted while instances exist");
                
            _context.Characters.Remove(character);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<bool> ExistsAsync(CharacterId id, CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .AnyAsync(c => c.Id == id, cancellationToken);
    }

    public async Task<int> CountAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Characters
            .CountAsync(cancellationToken);
    }
}
