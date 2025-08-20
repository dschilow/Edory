using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Edory.Character.Domain;
using System.Text.Json;

namespace Edory.Infrastructure.Data.Configurations;

/// <summary>
/// Entity Framework Configuration für CharacterInstance Entity
/// </summary>
public class CharacterInstanceConfiguration : IEntityTypeConfiguration<CharacterInstance>
{
    public void Configure(EntityTypeBuilder<CharacterInstance> builder)
    {
        builder.ToTable("CharacterInstances");

        // Primary Key
        builder.HasKey(ci => ci.Id);

        // Properties
        builder.Property(ci => ci.CreatedAt)
            .IsRequired();

        builder.Property(ci => ci.LastInteractionAt)
            .IsRequired();

        builder.Property(ci => ci.ExperienceCount)
            .IsRequired()
            .HasDefaultValue(0);

        builder.Property(ci => ci.CustomName)
            .HasMaxLength(100);

        // BaseDna as Owned Entity
        builder.OwnsOne(ci => ci.BaseDna, dna =>
        {
            dna.Property(d => d.Name)
                .HasColumnName("BaseName")
                .IsRequired()
                .HasMaxLength(100);

            dna.Property(d => d.Description)
                .HasColumnName("BaseDescription")
                .IsRequired()
                .HasMaxLength(1000);

            dna.Property(d => d.Appearance)
                .HasColumnName("BaseAppearance")
                .IsRequired()
                .HasMaxLength(500);

            dna.Property(d => d.Personality)
                .HasColumnName("BasePersonality")
                .IsRequired()
                .HasMaxLength(1000);

            dna.Property(d => d.MinAge)
                .HasColumnName("BaseMinAge")
                .IsRequired();

            dna.Property(d => d.MaxAge)
                .HasColumnName("BaseMaxAge")
                .IsRequired();

            // BaseTraits as owned type
            dna.OwnsOne(d => d.BaseTraits, traits =>
            {
                traits.Property(t => t.Courage)
                    .HasColumnName("BaseTraitsCourage");
                traits.Property(t => t.Creativity)
                    .HasColumnName("BaseTraitsCreativity");
                traits.Property(t => t.Helpfulness)
                    .HasColumnName("BaseTraitsHelpfulness");
                traits.Property(t => t.Humor)
                    .HasColumnName("BaseTraitsHumor");
                traits.Property(t => t.Wisdom)
                    .HasColumnName("BaseTraitsWisdom");
                traits.Property(t => t.Curiosity)
                    .HasColumnName("BaseTraitsCuriosity");
                traits.Property(t => t.Empathy)
                    .HasColumnName("BaseTraitsEmpathy");
                traits.Property(t => t.Persistence)
                    .HasColumnName("BaseTraitsPersistence");
            });
        });

        builder.OwnsOne(ci => ci.CurrentTraits, traits =>
        {
            traits.Property(t => t.Courage)
                .HasColumnName("CurrentCourage");
            traits.Property(t => t.Creativity)
                .HasColumnName("CurrentCreativity");
            traits.Property(t => t.Helpfulness)
                .HasColumnName("CurrentHelpfulness");
            traits.Property(t => t.Humor)
                .HasColumnName("CurrentHumor");
            traits.Property(t => t.Wisdom)
                .HasColumnName("CurrentWisdom");
            traits.Property(t => t.Curiosity)
                .HasColumnName("CurrentCuriosity");
            traits.Property(t => t.Empathy)
                .HasColumnName("CurrentEmpathy");
            traits.Property(t => t.Persistence)
                .HasColumnName("CurrentPersistence");
        });

        // Relationships
        builder.HasOne<Character.Domain.Character>()
            .WithMany()
            .HasForeignKey(ci => ci.OriginalCharacterId)
            .OnDelete(DeleteBehavior.Restrict);

        // Indexes for performance
        builder.HasIndex(ci => ci.OriginalCharacterId);
        builder.HasIndex(ci => ci.OwnerFamilyId);
        builder.HasIndex(ci => ci.LastInteractionAt);
        builder.HasIndex(ci => ci.CreatedAt);
    }
}
