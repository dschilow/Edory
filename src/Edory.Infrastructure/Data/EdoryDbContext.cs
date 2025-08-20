using Microsoft.EntityFrameworkCore;
using Edory.Character.Domain;
using Edory.SharedKernel.ValueObjects;
using Edory.Memory.Domain;

namespace Edory.Infrastructure.Data;

/// <summary>
/// Haupt-Database Context für die Edory Anwendung - VEREINFACHT
/// Fokus auf CharacterInstance Problem lösen
/// </summary>
public class EdoryDbContext : DbContext
{
    public EdoryDbContext(DbContextOptions<EdoryDbContext> options) : base(options) { }

    // Character Context
    public DbSet<Character.Domain.Character> Characters { get; set; } = null!;
    public DbSet<CharacterInstance> CharacterInstances { get; set; } = null!;

    // Memory Context - AKTIVIERT für CharacterMemory System
    public DbSet<CharacterMemory> CharacterMemories { get; set; } = null!;

    // Story Context vorerst deaktiviert
    // public DbSet<Story.Domain.Story> Stories { get; set; } = null!;

    // Learning Context - TODO: Implement when Learning Domain is complete
    // public DbSet<LearningProfile> LearningProfiles { get; set; } = null!;
    // public DbSet<LearningProgress> LearningProgress { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply Character und Memory configurations
        modelBuilder.ApplyConfiguration(new Edory.Infrastructure.Data.Configurations.CharacterConfiguration());
        modelBuilder.ApplyConfiguration(new Edory.Infrastructure.Data.Configurations.CharacterInstanceConfiguration());
        modelBuilder.ApplyConfiguration(new Edory.Infrastructure.Data.Configurations.CharacterMemoryConfiguration());

        // Configure Value Objects
        ConfigureValueObjects(modelBuilder);

        // Configure Business Rules
        ConfigureBusinessRules(modelBuilder);
    }

    private void ConfigureValueObjects(ModelBuilder modelBuilder)
    {
        // CharacterId Value Object
        modelBuilder.Entity<Character.Domain.Character>()
            .Property(c => c.Id)
            .HasConversion(
                id => id.Value,
                value => CharacterId.From(value));

        modelBuilder.Entity<Character.Domain.Character>()
            .Property(c => c.CreatorFamilyId)
            .HasConversion(
                id => id.Value,
                value => FamilyId.From(value));

        // CharacterInstance Value Objects
        modelBuilder.Entity<CharacterInstance>()
            .Property(ci => ci.Id)
            .HasConversion(
                id => id.Value,
                value => CharacterInstanceId.From(value));

        modelBuilder.Entity<CharacterInstance>()
            .Property(ci => ci.OriginalCharacterId)
            .HasConversion(
                id => id.Value,
                value => CharacterId.From(value));

        modelBuilder.Entity<CharacterInstance>()
            .Property(ci => ci.OwnerFamilyId)
            .HasConversion(
                id => id.Value,
                value => FamilyId.From(value));
    }

    private void ConfigureBusinessRules(ModelBuilder modelBuilder)
    {
        // Trait Constraints (0-100)
        var characterTraitConstraints = new[]
        {
            "BaseCourage", "BaseCreativity", "BaseHelpfulness", "BaseHumor",
            "BaseWisdom", "BaseCuriosity", "BaseEmpathy", "BasePersistence"
        };

        // Character constraints
        foreach (var trait in characterTraitConstraints)
        {
            modelBuilder.Entity<Character.Domain.Character>()
                .ToTable(t => t.HasCheckConstraint($"CK_Characters_{trait}", $"{trait} >= 0 AND {trait} <= 100"));
        }

        // CharacterInstance constraints - ANGEPASST für primitive Properties
        var instanceTraitConstraints = new[]
        {
            "BaseTraitsCourage", "BaseTraitsCreativity", "BaseTraitsHelpfulness", "BaseTraitsHumor",
            "BaseTraitsWisdom", "BaseTraitsCuriosity", "BaseTraitsEmpathy", "BaseTraitsPersistence",
            "CurrentCourage", "CurrentCreativity", "CurrentHelpfulness", "CurrentHumor",
            "CurrentWisdom", "CurrentCuriosity", "CurrentEmpathy", "CurrentPersistence"
        };

        foreach (var trait in instanceTraitConstraints)
        {
            modelBuilder.Entity<CharacterInstance>()
                .ToTable(t => t.HasCheckConstraint($"CK_CharacterInstances_{trait}", $"{trait} >= 0 AND {trait} <= 100"));
        }

        // Age constraints
        modelBuilder.Entity<Character.Domain.Character>()
            .ToTable(t => t.HasCheckConstraint("CK_Characters_AgeRange", "MinAge >= 0 AND MaxAge >= MinAge AND MaxAge <= 18"));

        modelBuilder.Entity<CharacterInstance>()
            .ToTable(t => t.HasCheckConstraint("CK_CharacterInstances_AgeRange", "BaseMinAge >= 0 AND BaseMaxAge >= BaseMinAge AND BaseMaxAge <= 18"));
    }

    /// <summary>
    /// Ensure database is created and migrations are applied
    /// </summary>
    public void EnsureCreated()
    {
        try
        {
            Database.Migrate();
            Console.WriteLine("✅ Database migrations applied successfully");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Database migration failed: {ex.Message}");
            throw;
        }
    }
}