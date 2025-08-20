using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Edory.Infrastructure.Migrations
{
    /// <summary>
    /// Vereinfachte CharacterInstance Struktur ohne Owned Types
    /// Behebt EF Core Tracking-Probleme endgültig
    /// </summary>
    public partial class SimplifiedCharacterInstance : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Lösche alte Tabellen-Struktur falls vorhanden
            migrationBuilder.DropTable(
                name: "CharacterMemories");

            migrationBuilder.DropTable(
                name: "CharacterInstances");

            migrationBuilder.DropTable(
                name: "Characters");

            // Characters Table (unverändert)
            migrationBuilder.CreateTable(
                name: "Characters",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatorFamilyId = table.Column<Guid>(type: "uuid", nullable: false),
                    IsPublic = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    AdoptionCount = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    
                    // CharacterDna Properties
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    Appearance = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    Personality = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    MinAge = table.Column<int>(type: "integer", nullable: false),
                    MaxAge = table.Column<int>(type: "integer", nullable: false),
                    
                    // BaseTraits Properties
                    BaseCourage = table.Column<int>(type: "integer", nullable: false),
                    BaseCreativity = table.Column<int>(type: "integer", nullable: false),
                    BaseHelpfulness = table.Column<int>(type: "integer", nullable: false),
                    BaseHumor = table.Column<int>(type: "integer", nullable: false),
                    BaseWisdom = table.Column<int>(type: "integer", nullable: false),
                    BaseCuriosity = table.Column<int>(type: "integer", nullable: false),
                    BaseEmpathy = table.Column<int>(type: "integer", nullable: false),
                    BasePersistence = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Characters", x => x.Id);
                    // Trait Constraints
                    table.CheckConstraint("CK_Characters_BaseCourage", "BaseCourage >= 0 AND BaseCourage <= 100");
                    table.CheckConstraint("CK_Characters_BaseCreativity", "BaseCreativity >= 0 AND BaseCreativity <= 100");
                    table.CheckConstraint("CK_Characters_BaseHelpfulness", "BaseHelpfulness >= 0 AND BaseHelpfulness <= 100");
                    table.CheckConstraint("CK_Characters_BaseHumor", "BaseHumor >= 0 AND BaseHumor <= 100");
                    table.CheckConstraint("CK_Characters_BaseWisdom", "BaseWisdom >= 0 AND BaseWisdom <= 100");
                    table.CheckConstraint("CK_Characters_BaseCuriosity", "BaseCuriosity >= 0 AND BaseCuriosity <= 100");
                    table.CheckConstraint("CK_Characters_BaseEmpathy", "BaseEmpathy >= 0 AND BaseEmpathy <= 100");
                    table.CheckConstraint("CK_Characters_BasePersistence", "BasePersistence >= 0 AND BasePersistence <= 100");
                    table.CheckConstraint("CK_Characters_AgeRange", "MinAge >= 0 AND MaxAge >= MinAge AND MaxAge <= 18");
                });

            // CharacterInstances Table - VEREINFACHTE STRUKTUR
            migrationBuilder.CreateTable(
                name: "CharacterInstances",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OriginalCharacterId = table.Column<Guid>(type: "uuid", nullable: false),
                    OwnerFamilyId = table.Column<Guid>(type: "uuid", nullable: false),
                    CustomName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastInteractionAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ExperienceCount = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    
                    // Base DNA Properties - PRIMITIVE SPALTEN
                    BaseName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    BaseDescription = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    BaseAppearance = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    BasePersonality = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    BaseMinAge = table.Column<int>(type: "integer", nullable: false),
                    BaseMaxAge = table.Column<int>(type: "integer", nullable: false),
                    
                    // Base Traits Properties - PRIMITIVE SPALTEN
                    BaseTraitsCourage = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsCreativity = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsHelpfulness = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsHumor = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsWisdom = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsCuriosity = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsEmpathy = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsPersistence = table.Column<int>(type: "integer", nullable: false),
                    
                    // Current Traits Properties - PRIMITIVE SPALTEN
                    CurrentCourage = table.Column<int>(type: "integer", nullable: false),
                    CurrentCreativity = table.Column<int>(type: "integer", nullable: false),
                    CurrentHelpfulness = table.Column<int>(type: "integer", nullable: false),
                    CurrentHumor = table.Column<int>(type: "integer", nullable: false),
                    CurrentWisdom = table.Column<int>(type: "integer", nullable: false),
                    CurrentCuriosity = table.Column<int>(type: "integer", nullable: false),
                    CurrentEmpathy = table.Column<int>(type: "integer", nullable: false),
                    CurrentPersistence = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CharacterInstances", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CharacterInstances_Characters_OriginalCharacterId",
                        column: x => x.OriginalCharacterId,
                        principalTable: "Characters",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    
                    // Base Traits Constraints
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsCourage", "BaseTraitsCourage >= 0 AND BaseTraitsCourage <= 100");
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsCreativity", "BaseTraitsCreativity >= 0 AND BaseTraitsCreativity <= 100");
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsHelpfulness", "BaseTraitsHelpfulness >= 0 AND BaseTraitsHelpfulness <= 100");
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsHumor", "BaseTraitsHumor >= 0 AND BaseTraitsHumor <= 100");
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsWisdom", "BaseTraitsWisdom >= 0 AND BaseTraitsWisdom <= 100");
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsCuriosity", "BaseTraitsCuriosity >= 0 AND BaseTraitsCuriosity <= 100");
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsEmpathy", "BaseTraitsEmpathy >= 0 AND BaseTraitsEmpathy <= 100");
                    table.CheckConstraint("CK_CharacterInstances_BaseTraitsPersistence", "BaseTraitsPersistence >= 0 AND BaseTraitsPersistence <= 100");

                    // Current Traits Constraints
                    table.CheckConstraint("CK_CharacterInstances_CurrentCourage", "CurrentCourage >= 0 AND CurrentCourage <= 100");
                    table.CheckConstraint("CK_CharacterInstances_CurrentCreativity", "CurrentCreativity >= 0 AND CurrentCreativity <= 100");
                    table.CheckConstraint("CK_CharacterInstances_CurrentHelpfulness", "CurrentHelpfulness >= 0 AND CurrentHelpfulness <= 100");
                    table.CheckConstraint("CK_CharacterInstances_CurrentHumor", "CurrentHumor >= 0 AND CurrentHumor <= 100");
                    table.CheckConstraint("CK_CharacterInstances_CurrentWisdom", "CurrentWisdom >= 0 AND CurrentWisdom <= 100");
                    table.CheckConstraint("CK_CharacterInstances_CurrentCuriosity", "CurrentCuriosity >= 0 AND CurrentCuriosity <= 100");
                    table.CheckConstraint("CK_CharacterInstances_CurrentEmpathy", "CurrentEmpathy >= 0 AND CurrentEmpathy <= 100");
                    table.CheckConstraint("CK_CharacterInstances_CurrentPersistence", "CurrentPersistence >= 0 AND CurrentPersistence <= 100");

                    // Age Range Constraint
                    table.CheckConstraint("CK_CharacterInstances_AgeRange", "BaseMinAge >= 0 AND BaseMaxAge >= BaseMinAge AND BaseMaxAge <= 18");
                });

            // CharacterMemories Table (unverändert)
            migrationBuilder.CreateTable(
                name: "CharacterMemories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CharacterInstanceId = table.Column<Guid>(type: "uuid", nullable: false),
                    MemoryType = table.Column<int>(type: "integer", nullable: false),
                    Content = table.Column<string>(type: "text", nullable: false),
                    EmotionalContext = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Importance = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastAccessedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ConsolidatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    RelatedStoryId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CharacterMemories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CharacterMemories_CharacterInstances_CharacterInstanceId",
                        column: x => x.CharacterInstanceId,
                        principalTable: "CharacterInstances",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    
                    table.CheckConstraint("CK_CharacterMemories_Importance", "Importance >= 0 AND Importance <= 100");
                    table.CheckConstraint("CK_CharacterMemories_Content", "LENGTH(TRIM(Content)) > 0");
                });

            // Indexes für Performance-Optimierung
            migrationBuilder.CreateIndex(
                name: "IX_Characters_IsPublic",
                table: "Characters",
                column: "IsPublic");

            migrationBuilder.CreateIndex(
                name: "IX_Characters_CreatedAt",
                table: "Characters",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_Characters_CreatorFamilyId",
                table: "Characters",
                column: "CreatorFamilyId");

            migrationBuilder.CreateIndex(
                name: "IX_Characters_Name",
                table: "Characters",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_OriginalCharacterId",
                table: "CharacterInstances",
                column: "OriginalCharacterId");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_OwnerFamilyId",
                table: "CharacterInstances",
                column: "OwnerFamilyId");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_LastInteractionAt",
                table: "CharacterInstances",
                column: "LastInteractionAt");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_Family_LastInteraction",
                table: "CharacterInstances",
                columns: new[] { "OwnerFamilyId", "LastInteractionAt" });

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_BaseName",
                table: "CharacterInstances",
                column: "BaseName");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterMemories_CharacterInstanceId",
                table: "CharacterMemories",
                column: "CharacterInstanceId");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterMemories_MemoryType",
                table: "CharacterMemories",
                column: "MemoryType");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterMemories_Importance",
                table: "CharacterMemories",
                column: "Importance");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterMemories_CreatedAt",
                table: "CharacterMemories",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterMemories_IsActive",
                table: "CharacterMemories",
                column: "IsActive");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CharacterMemories");

            migrationBuilder.DropTable(
                name: "CharacterInstances");

            migrationBuilder.DropTable(
                name: "Characters");
        }
    }
}