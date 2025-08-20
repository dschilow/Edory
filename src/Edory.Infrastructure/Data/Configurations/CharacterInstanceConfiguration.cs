using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Edory.Character.Domain;

namespace Edory.Infrastructure.Data.Configurations;

/// <summary>
/// Entity Framework Configuration für CharacterInstance Entity
/// VEREINFACHTE VERSION ohne Owned Types - behebt EF Tracking-Probleme
/// </summary>
public class CharacterInstanceConfiguration : IEntityTypeConfiguration<CharacterInstance>
{
    public void Configure(EntityTypeBuilder<CharacterInstance> builder)
    {
        builder.ToTable("CharacterInstances");

        // Primary Key
        builder.HasKey(ci => ci.Id);

        // Basis-Properties
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

        // Base DNA Properties - DIREKT als Spalten (KEINE Owned Types)
        builder.Property(ci => ci.BaseName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(ci => ci.BaseDescription)
            .IsRequired()
            .HasMaxLength(1000);

        builder.Property(ci => ci.BaseAppearance)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(ci => ci.BasePersonality)
            .IsRequired()
            .HasMaxLength(1000);

        builder.Property(ci => ci.BaseMinAge)
            .IsRequired();

        builder.Property(ci => ci.BaseMaxAge)
            .IsRequired();

        // Base Traits Properties - DIREKT als Spalten
        builder.Property(ci => ci.BaseTraitsCourage)
            .IsRequired();

        builder.Property(ci => ci.BaseTraitsCreativity)
            .IsRequired();

        builder.Property(ci => ci.BaseTraitsHelpfulness)
            .IsRequired();

        builder.Property(ci => ci.BaseTraitsHumor)
            .IsRequired();

        builder.Property(ci => ci.BaseTraitsWisdom)
            .IsRequired();

        builder.Property(ci => ci.BaseTraitsCuriosity)
            .IsRequired();

        builder.Property(ci => ci.BaseTraitsEmpathy)
            .IsRequired();

        builder.Property(ci => ci.BaseTraitsPersistence)
            .IsRequired();

        // Current Traits Properties - DIREKT als Spalten
        builder.Property(ci => ci.CurrentCourage)
            .IsRequired();

        builder.Property(ci => ci.CurrentCreativity)
            .IsRequired();

        builder.Property(ci => ci.CurrentHelpfulness)
            .IsRequired();

        builder.Property(ci => ci.CurrentHumor)
            .IsRequired();

        builder.Property(ci => ci.CurrentWisdom)
            .IsRequired();

        builder.Property(ci => ci.CurrentCuriosity)
            .IsRequired();

        builder.Property(ci => ci.CurrentEmpathy)
            .IsRequired();

        builder.Property(ci => ci.CurrentPersistence)
            .IsRequired();

        // Relationship zum ursprünglichen Character
        builder.HasOne<Character.Domain.Character>()
            .WithMany()
            .HasForeignKey(ci => ci.OriginalCharacterId)
            .OnDelete(DeleteBehavior.Cascade);

        // Check Constraints für Trait-Werte (0-100)
        builder.ToTable(t =>
        {
            // Base Traits Constraints
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsCourage", "BaseTraitsCourage >= 0 AND BaseTraitsCourage <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsCreativity", "BaseTraitsCreativity >= 0 AND BaseTraitsCreativity <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsHelpfulness", "BaseTraitsHelpfulness >= 0 AND BaseTraitsHelpfulness <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsHumor", "BaseTraitsHumor >= 0 AND BaseTraitsHumor <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsWisdom", "BaseTraitsWisdom >= 0 AND BaseTraitsWisdom <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsCuriosity", "BaseTraitsCuriosity >= 0 AND BaseTraitsCuriosity <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsEmpathy", "BaseTraitsEmpathy >= 0 AND BaseTraitsEmpathy <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_BaseTraitsPersistence", "BaseTraitsPersistence >= 0 AND BaseTraitsPersistence <= 100");

            // Current Traits Constraints
            t.HasCheckConstraint("CK_CharacterInstances_CurrentCourage", "CurrentCourage >= 0 AND CurrentCourage <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_CurrentCreativity", "CurrentCreativity >= 0 AND CurrentCreativity <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_CurrentHelpfulness", "CurrentHelpfulness >= 0 AND CurrentHelpfulness <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_CurrentHumor", "CurrentHumor >= 0 AND CurrentHumor <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_CurrentWisdom", "CurrentWisdom >= 0 AND CurrentWisdom <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_CurrentCuriosity", "CurrentCuriosity >= 0 AND CurrentCuriosity <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_CurrentEmpathy", "CurrentEmpathy >= 0 AND CurrentEmpathy <= 100");
            t.HasCheckConstraint("CK_CharacterInstances_CurrentPersistence", "CurrentPersistence >= 0 AND CurrentPersistence <= 100");

            // Age Range Constraint
            t.HasCheckConstraint("CK_CharacterInstances_AgeRange", "BaseMinAge >= 0 AND BaseMaxAge >= BaseMinAge AND BaseMaxAge <= 18");
        });

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

        // Index für Name-Suche
        builder.HasIndex(ci => ci.BaseName)
            .HasDatabaseName("IX_CharacterInstances_BaseName");
    }
}