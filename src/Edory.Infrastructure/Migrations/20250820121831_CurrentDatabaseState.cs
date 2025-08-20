using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Edory.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class CurrentDatabaseState : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Alle Tabellen existieren bereits in der Datenbank
            // Diese Migration dient nur dazu, den aktuellen Zustand zu erfassen
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Keine Tabellen werden gelöscht, da sie bereits existieren
        }
    }
}
