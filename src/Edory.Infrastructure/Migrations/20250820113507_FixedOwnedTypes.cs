using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Edory.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FixedOwnedTypes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "character_memories",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    character_instance_id = table.Column<Guid>(type: "uuid", nullable: false),
                    type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    last_updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    fragments = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_character_memories", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "Characters",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    BaseCourage = table.Column<int>(type: "integer", nullable: false),
                    BaseCreativity = table.Column<int>(type: "integer", nullable: false),
                    BaseHelpfulness = table.Column<int>(type: "integer", nullable: false),
                    BaseHumor = table.Column<int>(type: "integer", nullable: false),
                    BaseWisdom = table.Column<int>(type: "integer", nullable: false),
                    BaseCuriosity = table.Column<int>(type: "integer", nullable: false),
                    BaseEmpathy = table.Column<int>(type: "integer", nullable: false),
                    BasePersistence = table.Column<int>(type: "integer", nullable: false),
                    Appearance = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    Personality = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    MinAge = table.Column<int>(type: "integer", nullable: false),
                    MaxAge = table.Column<int>(type: "integer", nullable: false),
                    CreatorFamilyId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsPublic = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    AdoptionCount = table.Column<int>(type: "integer", nullable: false, defaultValue: 0)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Characters", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CharacterInstances",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OriginalCharacterId = table.Column<Guid>(type: "uuid", nullable: false),
                    OwnerFamilyId = table.Column<Guid>(type: "uuid", nullable: false),
                    BaseName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    BaseDescription = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    BaseTraitsCourage = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsCreativity = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsHelpfulness = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsHumor = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsWisdom = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsCuriosity = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsEmpathy = table.Column<int>(type: "integer", nullable: false),
                    BaseTraitsPersistence = table.Column<int>(type: "integer", nullable: false),
                    BaseAppearance = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    BasePersonality = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    BaseMinAge = table.Column<int>(type: "integer", nullable: false),
                    BaseMaxAge = table.Column<int>(type: "integer", nullable: false),
                    CurrentCourage = table.Column<int>(type: "integer", nullable: false),
                    CurrentCreativity = table.Column<int>(type: "integer", nullable: false),
                    CurrentHelpfulness = table.Column<int>(type: "integer", nullable: false),
                    CurrentHumor = table.Column<int>(type: "integer", nullable: false),
                    CurrentWisdom = table.Column<int>(type: "integer", nullable: false),
                    CurrentCuriosity = table.Column<int>(type: "integer", nullable: false),
                    CurrentEmpathy = table.Column<int>(type: "integer", nullable: false),
                    CurrentPersistence = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastInteractionAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ExperienceCount = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    CustomName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CharacterInstances", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CharacterInstances_Characters_OriginalCharacterId",
                        column: x => x.OriginalCharacterId,
                        principalTable: "Characters",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "ix_character_memories_character_instance_id",
                table: "character_memories",
                column: "character_instance_id");

            migrationBuilder.CreateIndex(
                name: "ix_character_memories_character_instance_type",
                table: "character_memories",
                columns: new[] { "character_instance_id", "type" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_character_memories_last_updated",
                table: "character_memories",
                column: "last_updated_at");

            migrationBuilder.CreateIndex(
                name: "ix_character_memories_type",
                table: "character_memories",
                column: "type");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_CreatedAt",
                table: "CharacterInstances",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_LastInteractionAt",
                table: "CharacterInstances",
                column: "LastInteractionAt");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_OriginalCharacterId",
                table: "CharacterInstances",
                column: "OriginalCharacterId");

            migrationBuilder.CreateIndex(
                name: "IX_CharacterInstances_OwnerFamilyId",
                table: "CharacterInstances",
                column: "OwnerFamilyId");

            migrationBuilder.CreateIndex(
                name: "IX_Characters_CreatedAt",
                table: "Characters",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_Characters_CreatorFamilyId",
                table: "Characters",
                column: "CreatorFamilyId");

            migrationBuilder.CreateIndex(
                name: "IX_Characters_IsPublic",
                table: "Characters",
                column: "IsPublic");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "character_memories");

            migrationBuilder.DropTable(
                name: "CharacterInstances");

            migrationBuilder.DropTable(
                name: "Characters");
        }
    }
}
