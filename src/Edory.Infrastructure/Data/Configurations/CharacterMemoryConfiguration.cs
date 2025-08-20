using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Edory.Memory.Domain;
using System.Text.Json;

namespace Edory.Infrastructure.Data.Configurations;

/// <summary>
/// EF Core Konfiguration für CharacterMemory
/// Definiert die PostgreSQL-Tabellenkonfiguration für das Gedächtnissystem
/// </summary>
public class CharacterMemoryConfiguration : IEntityTypeConfiguration<CharacterMemory>
{
    public void Configure(EntityTypeBuilder<CharacterMemory> builder)
    {
        // Tabellenname
        builder.ToTable("character_memories");

        // Primary Key
        builder.HasKey(m => m.Id);
        
        // ID-Konvertierung (MemoryId ValueObject -> Guid)
        builder.Property(m => m.Id)
            .HasConversion(
                id => id.Value,
                value => MemoryId.From(value))
            .HasColumnName("id");

        // CharacterInstanceId
        builder.Property(m => m.CharacterInstanceId)
            .IsRequired()
            .HasColumnName("character_instance_id");

        // Memory Type als Enum
        builder.Property(m => m.Type)
            .IsRequired()
            .HasConversion<string>() // Speichere als String in DB
            .HasMaxLength(20)
            .HasColumnName("type");

        // Zeitstempel
        builder.Property(m => m.CreatedAt)
            .IsRequired()
            .HasColumnName("created_at");

        builder.Property(m => m.LastUpdatedAt)
            .IsRequired()
            .HasColumnName("last_updated_at");

        // Memory Fragments als JSON
        builder.Property(m => m.Fragments)
            .HasConversion(
                fragments => JsonSerializer.Serialize(fragments.Select(ConvertFragmentToJson), (JsonSerializerOptions?)null),
                json => JsonSerializer.Deserialize<MemoryFragmentDto[]>(json, (JsonSerializerOptions?)null) != null
                    ? JsonSerializer.Deserialize<MemoryFragmentDto[]>(json, (JsonSerializerOptions?)null)!
                        .Select(ConvertJsonToFragment)
                        .ToList() 
                    : new List<MemoryFragment>(),
                new ValueComparer<IReadOnlyList<MemoryFragment>>(
                    (c1, c2) => c1!.SequenceEqual(c2!),
                    c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
                    c => c.ToList()))
            .HasColumnType("jsonb") // PostgreSQL JSONB für Performance
            .HasColumnName("fragments");

        // Index für bessere Performance
        builder.HasIndex(m => m.CharacterInstanceId)
            .HasDatabaseName("ix_character_memories_character_instance_id");

        builder.HasIndex(m => new { m.CharacterInstanceId, m.Type })
            .IsUnique()
            .HasDatabaseName("ix_character_memories_character_instance_type");

        builder.HasIndex(m => m.Type)
            .HasDatabaseName("ix_character_memories_type");

        builder.HasIndex(m => m.LastUpdatedAt)
            .HasDatabaseName("ix_character_memories_last_updated");
    }

    /// <summary>
    /// DTO für JSON-Serialisierung von MemoryFragment
    /// </summary>
    private class MemoryFragmentDto
    {
        public Guid Id { get; set; }
        public string Content { get; set; } = string.Empty;
        public string[] Tags { get; set; } = Array.Empty<string>();
        public MemoryImportance Importance { get; set; }
        public EmotionalContextDto EmotionalContext { get; set; } = new();
        public DateTime Timestamp { get; set; }
        public MemoryType Type { get; set; }
        public bool IsActive { get; set; }
    }

    /// <summary>
    /// DTO für JSON-Serialisierung von EmotionalContext
    /// </summary>
    private class EmotionalContextDto
    {
        public int Joy { get; set; }
        public int Sadness { get; set; }
        public int Fear { get; set; }
        public int Anger { get; set; }
        public int Surprise { get; set; }
        public int Pride { get; set; }
        public int Excitement { get; set; }
        public int Calmness { get; set; }
    }

    /// <summary>
    /// Konvertiert MemoryFragment zu DTO für JSON-Serialisierung
    /// </summary>
    private static MemoryFragmentDto ConvertFragmentToJson(MemoryFragment fragment)
    {
        return new MemoryFragmentDto
        {
            Id = fragment.Id,
            Content = fragment.Content,
            Tags = fragment.Tags,
            Importance = fragment.Importance,
            EmotionalContext = new EmotionalContextDto
            {
                Joy = fragment.EmotionalContext.Joy,
                Sadness = fragment.EmotionalContext.Sadness,
                Fear = fragment.EmotionalContext.Fear,
                Anger = fragment.EmotionalContext.Anger,
                Surprise = fragment.EmotionalContext.Surprise,
                Pride = fragment.EmotionalContext.Pride,
                Excitement = fragment.EmotionalContext.Excitement,
                Calmness = fragment.EmotionalContext.Calmness
            },
            Timestamp = fragment.Timestamp,
            Type = fragment.Type,
            IsActive = fragment.IsActive
        };
    }

    /// <summary>
    /// Konvertiert DTO zu MemoryFragment
    /// </summary>
    private static MemoryFragment ConvertJsonToFragment(MemoryFragmentDto dto)
    {
        var emotionalContext = EmotionalContext.Create(
            dto.EmotionalContext.Joy,
            dto.EmotionalContext.Sadness,
            dto.EmotionalContext.Fear,
            dto.EmotionalContext.Anger,
            dto.EmotionalContext.Surprise,
            dto.EmotionalContext.Pride,
            dto.EmotionalContext.Excitement,
            dto.EmotionalContext.Calmness);

        var fragment = MemoryFragment.Create(
            dto.Content,
            dto.Tags,
            dto.Type,
            dto.Importance,
            emotionalContext,
            dto.Timestamp);

        // Setze die ID über Reflection (da private)
        var idField = typeof(MemoryFragment).BaseType!
            .GetField("_id", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        idField?.SetValue(fragment, dto.Id);

        // Setze IsActive falls deaktiviert
        if (!dto.IsActive)
        {
            fragment.Deactivate();
        }

        return fragment;
    }
}

