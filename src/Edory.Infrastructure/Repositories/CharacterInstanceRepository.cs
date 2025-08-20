using Microsoft.EntityFrameworkCore;
using Edory.Character.Domain;
using Edory.Character.Domain.Repositories;
using Edory.Infrastructure.Data;

namespace Edory.Infrastructure.Repositories;

/// <summary>
/// PostgreSQL Implementation des CharacterInstance Repository
/// ANGEPASST für vereinfachte CharacterInstance ohne Owned Types
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
            .OrderBy(ci => ci.BaseName) // Verwende BaseName statt BaseDna.Name
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

    /// <summary>
    /// Sucht CharacterInstances nach Name (BaseName oder CustomName)
    /// </summary>
    public async Task<IReadOnlyList<CharacterInstance>> SearchByNameAsync(
        string searchTerm, 
        FamilyId? familyId = null, 
        CancellationToken cancellationToken = default)
    {
        var query = _context.CharacterInstances.AsQueryable();
        
        if (familyId.HasValue)
        {
            query = query.Where(ci => ci.OwnerFamilyId == familyId.Value);
        }
        
        return await query
            .Where(ci => ci.BaseName.Contains(searchTerm) || 
                        (ci.CustomName != null && ci.CustomName.Contains(searchTerm)))
            .OrderBy(ci => ci.BaseName)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Gibt Statistiken über Trait-Entwicklung zurück
    /// </summary>
    public async Task<Dictionary<string, double>> GetTraitEvolutionStatsAsync(
        CharacterInstanceId instanceId, 
        CancellationToken cancellationToken = default)
    {
        var instance = await GetByIdAsync(instanceId, cancellationToken);
        if (instance == null)
            return new Dictionary<string, double>();

        return new Dictionary<string, double>
        {
            ["CourageEvolution"] = instance.CurrentCourage - instance.BaseTraitsCourage,
            ["CreativityEvolution"] = instance.CurrentCreativity - instance.BaseTraitsCreativity,
            ["HelpfulnessEvolution"] = instance.CurrentHelpfulness - instance.BaseTraitsHelpfulness,
            ["HumorEvolution"] = instance.CurrentHumor - instance.BaseTraitsHumor,
            ["WisdomEvolution"] = instance.CurrentWisdom - instance.BaseTraitsWisdom,
            ["CuriosityEvolution"] = instance.CurrentCuriosity - instance.BaseTraitsCuriosity,
            ["EmpathyEvolution"] = instance.CurrentEmpathy - instance.BaseTraitsEmpathy,
            ["PersistenceEvolution"] = instance.CurrentPersistence - instance.BaseTraitsPersistence,
            ["AverageEvolution"] = new[]
            {
                instance.CurrentCourage - instance.BaseTraitsCourage,
                instance.CurrentCreativity - instance.BaseTraitsCreativity,
                instance.CurrentHelpfulness - instance.BaseTraitsHelpfulness,
                instance.CurrentHumor - instance.BaseTraitsHumor,
                instance.CurrentWisdom - instance.BaseTraitsWisdom,
                instance.CurrentCuriosity - instance.BaseTraitsCuriosity,
                instance.CurrentEmpathy - instance.BaseTraitsEmpathy,
                instance.CurrentPersistence - instance.BaseTraitsPersistence
            }.Average()
        };
    }

    /// <summary>
    /// Gibt CharacterInstances mit den höchsten Trait-Werten zurück
    /// </summary>
    public async Task<IReadOnlyList<CharacterInstance>> GetTopCharactersByTraitAsync(
        string traitName, 
        FamilyId familyId, 
        int count = 5, 
        CancellationToken cancellationToken = default)
    {
        var query = _context.CharacterInstances
            .Where(ci => ci.OwnerFamilyId == familyId);

        query = traitName.ToLower() switch
        {
            "courage" => query.OrderByDescending(ci => ci.CurrentCourage),
            "creativity" => query.OrderByDescending(ci => ci.CurrentCreativity),
            "helpfulness" => query.OrderByDescending(ci => ci.CurrentHelpfulness),
            "humor" => query.OrderByDescending(ci => ci.CurrentHumor),
            "wisdom" => query.OrderByDescending(ci => ci.CurrentWisdom),
            "curiosity" => query.OrderByDescending(ci => ci.CurrentCuriosity),
            "empathy" => query.OrderByDescending(ci => ci.CurrentEmpathy),
            "persistence" => query.OrderByDescending(ci => ci.CurrentPersistence),
            _ => query.OrderByDescending(ci => ci.LastInteractionAt)
        };

        return await query
            .Take(count)
            .ToListAsync(cancellationToken);
    }
}