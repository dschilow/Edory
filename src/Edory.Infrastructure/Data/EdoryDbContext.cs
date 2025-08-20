using Microsoft.EntityFrameworkCore;
using Avatales.Character.Domain;
using Avatales.Memory.Domain;
using Avatales.Story.Domain;
using Avatales.Learning.Domain;
using Avatales.SharedKernel.ValueObjects;

namespace Edory.Infrastructure.Data;

/// <summary>
/// Haupt-Database Context für die Edory Anwendung
/// Verwaltet alle Bounded Contexts in einer gemeinsamen Datenbank
/// </summary>
public class EdoryDbContext : DbContext
{
    public EdoryDbContext(DbContextOptions<AvatalesDbContext> options) : base(options) { }

    // Character Context
    public DbSet<Character.Domain.Character> Characters { get; set; } = null!;
    public DbSet<CharacterInstance> CharacterInstances { get; set; } = null!;

    // Memory Context
    public DbSet<CharacterMemory> CharacterMemories { get; set; } = null!;

    // Story Context vorerst deaktiviert (fehlende EF-Mappings)
    // public DbSet<Story.Domain.Story> Stories { get; set; } = null!;

    // Learning Context - TODO: Implement when Learning Domain is complete
    // public DbSet<LearningProfile> LearningProfiles { get; set; } = null!;
    // public DbSet<LearningProgress> LearningProgress { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply configurations from all contexts
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AvatalesDbContext).Assembly);

        // Configure Value Objects as owned types
        ConfigureValueObjects(modelBuilder);

        // Configure additional constraints and relationships
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

        // CharacterMemory Value Objects
        modelBuilder.Entity<CharacterMemory>()
            .Property(cm => cm.Id)
            .HasConversion(
                id => id.Value,
                value => MemoryId.From(value));

        modelBuilder.Entity<CharacterMemory>()
            .Property(cm => cm.CharacterInstanceId)
            .HasConversion(
                id => id.Value,
                value => CharacterInstanceId.From(value));

        // StoryId Value Object (wenn aktiviert)
        // modelBuilder.Entity<CharacterMemory>()
        //     .Property(cm => cm.RelatedStoryId)
        //     .HasConversion(
        //         id => id.HasValue ? id.Value.Value : (Guid?)null,
        //         value => value.HasValue ? StoryId.From(value.Value) : null);
    }

    private void ConfigureBusinessRules(ModelBuilder modelBuilder)
    {
        // Trait Constraints (0-100 für alle Eigenschaften)
        var traitConstraints = new[]
        {
            "BaseCourage", "BaseCreativity", "BaseHelpfulness", "BaseHumor",
            "BaseWisdom", "BaseCuriosity", "BaseEmpathy", "BasePersistence",
            "CurrentTraitsCourage", "CurrentTraitsCreativity", "CurrentTraitsHelpfulness",
            "CurrentTraitsHumor", "CurrentTraitsWisdom", "CurrentTraitsCuriosity",
            "CurrentTraitsEmpathy", "CurrentTraitsPersistence"
        };

        // Add check constraints for Characters table
        foreach (var trait in traitConstraints.Where(t => t.StartsWith("Base")))
        {
            modelBuilder.Entity<Character.Domain.Character>()
                .ToTable(t => t.HasCheckConstraint($"CK_Characters_{trait}", $"{trait} >= 0 AND {trait} <= 100"));
        }

        // Add check constraints for CharacterInstances table
        foreach (var trait in traitConstraints.Where(t => !t.StartsWith("Base") || t.Contains("Traits")))
        {
            modelBuilder.Entity<CharacterInstance>()
                .ToTable(t => t.HasCheckConstraint($"CK_CharacterInstances_{trait}", $"{trait} >= 0 AND {trait} <= 100"));
        }

        // Age constraints
        modelBuilder.Entity<Character.Domain.Character>()
            .ToTable(t => t.HasCheckConstraint("CK_Characters_AgeRange", "MinAge >= 0 AND MaxAge >= MinAge AND MaxAge <= 18"));

        // Memory Importance constraints
        modelBuilder.Entity<CharacterMemory>()
            .ToTable(t => t.HasCheckConstraint("CK_CharacterMemories_Importance", "Importance >= 0 AND Importance <= 100"));

        // Memory Content nicht leer
        modelBuilder.Entity<CharacterMemory>()
            .ToTable(t => t.HasCheckConstraint("CK_CharacterMemories_Content", "LENGTH(TRIM(Content)) > 0"));
    }

    /// <summary>
    /// Ensure database is created and migrations are applied
    /// Called automatically from Program.cs
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