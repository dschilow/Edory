using Microsoft.EntityFrameworkCore;
using Edory.Character.Domain;
using Edory.Character.Domain.Repositories;
using Edory.Infrastructure.Data;

namespace Edory.Infrastructure.Repositories;

/// <summary>
/// PostgreSQL Implementation des CharacterInstance Repository
/// </summary>
public class CharacterInstanceRepository : ICharacterInstanceRepository
{
    private readonly EdoryDbContext _context;

    public CharacterInstanceRepository(EdoryDbContext context)
    {
        _context = context;
    }

    public async Task<CharacterInstance?> GetByIdAsync(CharacterInstanceId id, CancellationToken cancellationToken = default)
    {
        return await _context.CharacterInstances
            .FirstOrDefaultAsync(ci => ci.Id == id, cancellationToken);
    }

    public async Task<IReadOnlyList<CharacterInstance>> GetByFamilyAsync(FamilyId familyId, CancellationToken cancellationToken = default)
    {
        return await _context.CharacterInstances
            .Where(ci => ci.OwnerFamilyId == familyId)
            .OrderBy(ci => ci.BaseDna.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CharacterInstance>> GetByOriginalCharacterAsync(CharacterId originalCharacterId, CancellationToken cancellationToken = default)
    {
        return await _context.CharacterInstances
            .Where(ci => ci.OriginalCharacterId == originalCharacterId)
            .OrderBy(ci => ci.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<CharacterInstance?> GetByCharacterAndFamilyAsync(CharacterId characterId, FamilyId familyId, CancellationToken cancellationToken = default)
    {
        return await _context.CharacterInstances
            .FirstOrDefaultAsync(ci => ci.OriginalCharacterId == characterId && ci.OwnerFamilyId == familyId, cancellationToken);
    }

    public async Task<IReadOnlyList<CharacterInstance>> GetMostActiveAsync(FamilyId familyId, int count = 10, CancellationToken cancellationToken = default)
    {
        return await _context.CharacterInstances
            .Where(ci => ci.OwnerFamilyId == familyId)
            .OrderByDescending(ci => ci.LastInteractionAt)
            .Take(count)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(CharacterInstance instance, CancellationToken cancellationToken = default)
    {
        await _context.CharacterInstances.AddAsync(instance, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(CharacterInstance instance, CancellationToken cancellationToken = default)
    {
        _context.CharacterInstances.Update(instance);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(CharacterInstanceId id, CancellationToken cancellationToken = default)
    {
        var instance = await GetByIdAsync(id, cancellationToken);
        if (instance != null)
        {
            _context.CharacterInstances.Remove(instance);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}