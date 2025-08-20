using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Edory.Character.Domain;

namespace Edory.Infrastructure.Data.Configurations;

/// <summary>
/// Entity Framework Configuration für CharacterInstance Entity
/// Korrigierte Version ohne EF Tracking-Konflikte
/// </summary>
public class CharacterInstanceConfiguration : IEntityTypeConfiguration<CharacterInstance>
{
    public void Configure(EntityTypeBuilder<CharacterInstance> builder)
    {
        builder.ToTable("CharacterInstances");

        // Primary Key
        builder.HasKey(ci => ci.Id);

        // Properties
        builder.Property(ci => ci.OriginalCharacterId)
            .IsRequired();

        builder.Property(ci => ci.OwnerFamilyId)
            .IsRequired();

        builder.Property(ci => ci.CustomName)
            .HasMaxLength(100)
            .IsRequired(false);

        builder.Property(ci => ci.CreatedAt)
            .IsRequired();

        builder.Property(ci => ci.LastInteractionAt)
            .IsRequired();

        builder.Property(ci => ci.ExperienceCount)
            .IsRequired()
            .HasDefaultValue(0);

        // BaseDna als Owned Entity - VEREINFACHT
        builder.OwnsOne(ci => ci.BaseDna, baseDna =>
        {
            baseDna.Property(d => d.Name)
                .HasColumnName("BaseName")
                .IsRequired()
                .HasMaxLength(100);

            baseDna.Property(d => d.Description)
                .HasColumnName("BaseDescription")
                .IsRequired()
                .HasMaxLength(1000);

            baseDna.Property(d => d.Appearance)
                .HasColumnName("BaseAppearance")
                .IsRequired()
                .HasMaxLength(500);

            baseDna.Property(d => d.Personality)
                .HasColumnName("BasePersonality")
                .IsRequired()
                .HasMaxLength(1000);

            baseDna.Property(d => d.MinAge)
                .HasColumnName("BaseMinAge")
                .IsRequired();

            baseDna.Property(d => d.MaxAge)
                .HasColumnName("BaseMaxAge")
                .IsRequired();

            // BaseTraits direkt als Properties - KORRIGIERT
            baseDna.OwnsOne(d => d.BaseTraits, baseTraits =>
            {
                baseTraits.Property(t => t.Courage)
                    .HasColumnName("BaseTraitsCourage")
                    .IsRequired();
                baseTraits.Property(t => t.Creativity)
                    .HasColumnName("BaseTraitsCreativity")
                    .IsRequired();
                baseTraits.Property(t => t.Helpfulness)
                    .HasColumnName("BaseTraitsHelpfulness")
                    .IsRequired();
                baseTraits.Property(t => t.Humor)
                    .HasColumnName("BaseTraitsHumor")
                    .IsRequired();
                baseTraits.Property(t => t.Wisdom)
                    .HasColumnName("BaseTraitsWisdom")
                    .IsRequired();
                baseTraits.Property(t => t.Curiosity)
                    .HasColumnName("BaseTraitsCuriosity")
                    .IsRequired();
                baseTraits.Property(t => t.Empathy)
                    .HasColumnName("BaseTraitsEmpathy")
                    .IsRequired();
                baseTraits.Property(t => t.Persistence)
                    .HasColumnName("BaseTraitsPersistence")
                    .IsRequired();
            });
        });

        // CurrentTraits als separates Owned Entity - KORRIGIERT
        builder.OwnsOne(ci => ci.CurrentTraits, currentTraits =>
        {
            currentTraits.Property(t => t.Courage)
                .HasColumnName("CurrentCourage")
                .IsRequired();
            currentTraits.Property(t => t.Creativity)
                .HasColumnName("CurrentCreativity")
                .IsRequired();
            currentTraits.Property(t => t.Helpfulness)
                .HasColumnName("CurrentHelpfulness")
                .IsRequired();
            currentTraits.Property(t => t.Humor)
                .HasColumnName("CurrentHumor")
                .IsRequired();
            currentTraits.Property(t => t.Wisdom)
                .HasColumnName("CurrentWisdom")
                .IsRequired();
            currentTraits.Property(t => t.Curiosity)
                .HasColumnName("CurrentCuriosity")
                .IsRequired();
            currentTraits.Property(t => t.Empathy)
                .HasColumnName("CurrentEmpathy")
                .IsRequired();
            currentTraits.Property(t => t.Persistence)
                .HasColumnName("CurrentPersistence")
                .IsRequired();
        });

        // Relationship zum ursprünglichen Character
        builder.HasOne<Character.Domain.Character>()
            .WithMany()
            .HasForeignKey(ci => ci.OriginalCharacterId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes für Performance
        builder.HasIndex(ci => ci.OriginalCharacterId)
            .HasDatabaseName("IX_CharacterInstances_OriginalCharacterId");
            
        builder.HasIndex(ci => ci.OwnerFamilyId)
            .HasDatabaseName("IX_CharacterInstances_OwnerFamilyId");
            
        builder.HasIndex(ci => ci.LastInteractionAt)
            .HasDatabaseName("IX_CharacterInstances_LastInteractionAt");

        // Composite Index für häufige Abfragen
        builder.HasIndex(ci => new { ci.OwnerFamilyId, ci.LastInteractionAt })
            .HasDatabaseName("IX_CharacterInstances_Family_LastInteraction");
    }
}