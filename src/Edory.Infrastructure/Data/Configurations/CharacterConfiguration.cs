using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Edory.Character.Domain;
using Edory.SharedKernel.ValueObjects;
using System.Text.Json;

namespace Edory.Infrastructure.Data.Configurations;

/// <summary>
/// Entity Framework Configuration für Character Entity
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

        // CharacterDna as Owned Entity
        builder.OwnsOne(c => c.Dna, dna =>
        {
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

            // BaseTraits as owned type
            dna.OwnsOne(d => d.BaseTraits, traits =>
            {
                traits.Property(t => t.Courage)
                    .HasColumnName("BaseCourage");
                traits.Property(t => t.Creativity)
                    .HasColumnName("BaseCreativity");
                traits.Property(t => t.Helpfulness)
                    .HasColumnName("BaseHelpfulness");
                traits.Property(t => t.Humor)
                    .HasColumnName("BaseHumor");
                traits.Property(t => t.Wisdom)
                    .HasColumnName("BaseWisdom");
                traits.Property(t => t.Curiosity)
                    .HasColumnName("BaseCuriosity");
                traits.Property(t => t.Empathy)
                    .HasColumnName("BaseEmpathy");
                traits.Property(t => t.Persistence)
                    .HasColumnName("BasePersistence");
            });
        });

        // Indexes for performance
        builder.HasIndex(c => c.IsPublic);
        builder.HasIndex(c => c.CreatedAt);
        builder.HasIndex(c => c.CreatorFamilyId);
    }
}
