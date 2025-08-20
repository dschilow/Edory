using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Edory.Character.Domain;
using Edory.SharedKernel.ValueObjects;

namespace Edory.Infrastructure.Data.Configurations;

/// <summary>
/// Entity Framework Configuration für Character Entity
/// Korrigierte Version ohne Tracking-Konflikte bei Owned Types
/// </summary>
public class CharacterConfiguration : IEntityTypeConfiguration<Character.Domain.Character>
{
    public void Configure(EntityTypeBuilder<Character.Domain.Character> builder)
    {
        builder.ToTable("Characters");

        // Primary Key
        builder.HasKey(c => c.Id);
        
        // Properties  
        builder.Property(c => c.CreatedAt)
            .IsRequired();

        builder.Property(c => c.IsPublic)
            .IsRequired()
            .HasDefaultValue(false);

        builder.Property(c => c.AdoptionCount)
            .IsRequired()
            .HasDefaultValue(0);

        // CharacterDna als Owned Entity - KORRIGIERT
        builder.OwnsOne(c => c.Dna, dna =>
        {
            // DNA Basis-Properties
            dna.Property(d => d.Name)
                .HasColumnName("Name")
                .IsRequired()
                .HasMaxLength(100);

            dna.Property(d => d.Description)
                .HasColumnName("Description")
                .IsRequired()
                .HasMaxLength(1000);

            dna.Property(d => d.Appearance)
                .HasColumnName("Appearance")
                .IsRequired()
                .HasMaxLength(500);

            dna.Property(d => d.Personality)
                .HasColumnName("Personality")
                .IsRequired()
                .HasMaxLength(1000);

            dna.Property(d => d.MinAge)
                .HasColumnName("MinAge")
                .IsRequired();

            dna.Property(d => d.MaxAge)
                .HasColumnName("MaxAge")
                .IsRequired();

            // BaseTraits als Value Object - KORRIGIERT mit eindeutigen Spalten
            dna.OwnsOne(d => d.BaseTraits, traits =>
            {
                traits.Property(t => t.Courage)
                    .HasColumnName("BaseCourage")
                    .IsRequired();
                traits.Property(t => t.Creativity)
                    .HasColumnName("BaseCreativity")
                    .IsRequired();
                traits.Property(t => t.Helpfulness)
                    .HasColumnName("BaseHelpfulness")
                    .IsRequired();
                traits.Property(t => t.Humor)
                    .HasColumnName("BaseHumor")
                    .IsRequired();
                traits.Property(t => t.Wisdom)
                    .HasColumnName("BaseWisdom")
                    .IsRequired();
                traits.Property(t => t.Curiosity)
                    .HasColumnName("BaseCuriosity")
                    .IsRequired();
                traits.Property(t => t.Empathy)
                    .HasColumnName("BaseEmpathy")
                    .IsRequired();
                traits.Property(t => t.Persistence)
                    .HasColumnName("BasePersistence")
                    .IsRequired();
            });
        });

        // Indexes für Performance
        builder.HasIndex(c => c.IsPublic)
            .HasDatabaseName("IX_Characters_IsPublic");
            
        builder.HasIndex(c => c.CreatedAt)
            .HasDatabaseName("IX_Characters_CreatedAt");
            
        builder.HasIndex(c => c.CreatorFamilyId)
            .HasDatabaseName("IX_Characters_CreatorFamilyId");

        // Hinweis: Name-Index wird über SQL-Query optimiert, da Owned Type-Indizes komplex sind
    }
}