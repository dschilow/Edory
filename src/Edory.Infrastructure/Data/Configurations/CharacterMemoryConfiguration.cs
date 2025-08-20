using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Avatales.Memory.Domain;

namespace Avatales.Infrastructure.Data.Configurations;

/// <summary>
/// Entity Framework Configuration für CharacterMemory Entity
/// Konfiguriert das hierarchische AI-Memory-System (Acute -> Thematic -> Personality)
/// </summary>
public class CharacterMemoryConfiguration : IEntityTypeConfiguration<CharacterMemory>
{
    public void Configure(EntityTypeBuilder<CharacterMemory> builder)
    {
        builder.ToTable("CharacterMemories");

        // Primary Key
        builder.HasKey(cm => cm.Id);

        // Properties
        builder.Property(cm => cm.CharacterInstanceId)
            .IsRequired();

        builder.Property(cm => cm.MemoryType)
            .IsRequired()
            .HasConversion<int>(); // Enum to int conversion

        builder.Property(cm => cm.Content)
            .IsRequired()
            .HasColumnType("text"); // Für längere Texte

        builder.Property(cm => cm.EmotionalContext)
            .HasMaxLength(500)
            .IsRequired(false);

        builder.Property(cm => cm.Importance)
            .IsRequired();

        builder.Property(cm => cm.CreatedAt)
            .IsRequired();

        builder.Property(cm => cm.LastAccessedAt)
            .IsRequired();

        builder.Property(cm => cm.ConsolidatedAt)
            .IsRequired(false);

        builder.Property(cm => cm.IsActive)
            .IsRequired()
            .HasDefaultValue(true);

        builder.Property(cm => cm.RelatedStoryId)
            .IsRequired(false);

        // Relationship zur CharacterInstance
        builder.HasOne<Character.Domain.CharacterInstance>()
            .WithMany()
            .HasForeignKey(cm => cm.CharacterInstanceId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes für Performance-Optimierung des Memory-Systems
        builder.HasIndex(cm => cm.CharacterInstanceId)
            .HasDatabaseName("IX_CharacterMemories_CharacterInstanceId");

        builder.HasIndex(cm => cm.MemoryType)
            .HasDatabaseName("IX_CharacterMemories_MemoryType");

        builder.HasIndex(cm => cm.Importance)
            .HasDatabaseName("IX_CharacterMemories_Importance");

        builder.HasIndex(cm => cm.CreatedAt)
            .HasDatabaseName("IX_CharacterMemories_CreatedAt");

        builder.HasIndex(cm => cm.IsActive)
            .HasDatabaseName("IX_CharacterMemories_IsActive");

        // Composite Index für Memory-Konsolidierung
        builder.HasIndex(cm => new { cm.CharacterInstanceId, cm.MemoryType, cm.IsActive })
            .HasDatabaseName("IX_CharacterMemories_Consolidation");

        // Index für Memory-Cleanup basierend auf Importance und Zugriff
        builder.HasIndex(cm => new { cm.Importance, cm.LastAccessedAt, cm.IsActive })
            .HasDatabaseName("IX_CharacterMemories_Cleanup");
    }
}