using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Edory.Character.Domain;
using Edory.SharedKernel.ValueObjects;

namespace Edory.Infrastructure.Data.Configurations;

/// <summary>
/// Entity Framework Configuration für CharacterInstance Entity
/// Vereinfachte Version ohne Owned Types
/// </summary>
public class CharacterInstanceConfiguration : IEntityTypeConfiguration<CharacterInstance>
{
    public void Configure(EntityTypeBuilder<CharacterInstance> builder)
    {
        builder.ToTable("CharacterInstances");

        // Primary Key
        builder.HasKey(ci => ci.Id);
        
        // ID-Konvertierung (CharacterInstanceId ValueObject -> Guid)
        builder.Property(ci => ci.Id)
            .HasConversion(
                id => id.Value,
                value => CharacterInstanceId.From(value));

        // OriginalCharacterId
        builder.Property(ci => ci.OriginalCharacterId)
            .HasConversion(
                id => id.Value,
                value => CharacterId.From(value))
            .IsRequired();

        // OwnerFamilyId
        builder.Property(ci => ci.OwnerFamilyId)
            .HasConversion(
                id => id.Value,
                value => FamilyId.From(value))
            .IsRequired();

        // Basis-Properties
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

        // Base Traits
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

        // Current Traits
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

        // Weitere Properties
        builder.Property(ci => ci.CustomName)
            .HasMaxLength(100);

        builder.Property(ci => ci.CreatedAt)
            .IsRequired();

        builder.Property(ci => ci.LastInteractionAt)
            .IsRequired();

        builder.Property(ci => ci.ExperienceCount)
            .IsRequired()
            .HasDefaultValue(0);

        // Foreign Key zu Characters
        builder.HasOne<Character.Domain.Character>()
            .WithMany()
            .HasForeignKey(ci => ci.OriginalCharacterId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes für Performance
        builder.HasIndex(ci => ci.BaseName)
            .HasDatabaseName("IX_CharacterInstances_BaseName");

        builder.HasIndex(ci => ci.OwnerFamilyId)
            .HasDatabaseName("IX_CharacterInstances_OwnerFamilyId");

        builder.HasIndex(ci => ci.OriginalCharacterId)
            .HasDatabaseName("IX_CharacterInstances_OriginalCharacterId");

        builder.HasIndex(ci => ci.LastInteractionAt)
            .HasDatabaseName("IX_CharacterInstances_LastInteractionAt");

        builder.HasIndex(ci => new { ci.OwnerFamilyId, ci.LastInteractionAt })
            .HasDatabaseName("IX_CharacterInstances_Family_LastInteraction");
    }
}