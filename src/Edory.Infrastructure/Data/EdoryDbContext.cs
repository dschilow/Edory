using Microsoft.EntityFrameworkCore;
using Edory.Character.Domain;
using Edory.Memory.Domain;
using Edory.Story.Domain;
using Edory.Learning.Domain;

namespace Edory.Infrastructure.Data;

/// <summary>
/// Haupt-Database Context für die Edory Anwendung
/// Verwaltet alle Bounded Contexts in einer gemeinsamen Datenbank
/// </summary>
public class EdoryDbContext : DbContext
{
    public EdoryDbContext(DbContextOptions<EdoryDbContext> options) : base(options) { }

    // Character Context
    public DbSet<Character.Domain.Character> Characters { get; set; } = null!;
    public DbSet<CharacterInstance> CharacterInstances { get; set; } = null!;

    // Memory Context
    public DbSet<CharacterMemory> CharacterMemories { get; set; } = null!;

    // Story Context vorerst deaktiviert (fehlende EF-Mappings)
    // public DbSet<Story.Domain.Story> Stories { get; set; } = null!;

    // Learning Context - TODO: Implement when Learning Domain is complete
    // public DbSet<LearningProfile> LearningProfiles { get; set; } = null!;
    // public DbSet<LearningProgress> LearningProgress { get; set; } = null!

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply configurations from all contexts
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(EdoryDbContext).Assembly);

        // Configure Value Objects as owned types
        ConfigureValueObjects(modelBuilder);
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

        // FamilyId Value Object
        modelBuilder.Entity<CharacterInstance>()
            .Property(ci => ci.OwnerFamilyId)
            .HasConversion(
                id => id.Value,
                value => FamilyId.From(value));

        // StoryId Value Object vorerst deaktiviert (Story-Mapping ausgesetzt)
        // modelBuilder.Entity<Story.Domain.Story>()
        //     .Property(s => s.Id)
        //     .HasConversion(
        //         id => id.Value,
        //         value => StoryId.From(value));

        // MemoryId Value Objects
        modelBuilder.Entity<CharacterMemory>()
            .Property(cm => cm.Id)
            .HasConversion(
                id => id.Value,
                value => MemoryId.From(value));

        // LearningProfile Value Objects - TODO: Implement when Learning Domain is complete
        // modelBuilder.Entity<LearningProfile>()
        //     .Property(lp => lp.Id)
        //     .HasConversion(
        //         id => id.Value,
        //         value => new LearningProfileId(value));

        // modelBuilder.Entity<LearningProgress>()
        //     .Property(lp => lp.Id)
        //     .HasConversion(
        //         id => id.Value,
        //         value => new LearningProgressId(value));
    }
}
