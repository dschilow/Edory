# Avatales Database Migration Script
# Erstellt und führt die erste EF Core Migration aus

Write-Host "🚀 Avatales Database Migration Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Prüfe ob wir im richtigen Verzeichnis sind
$currentDir = Get-Location
$projectPath = "src\Avatales.Api"
$infrastructurePath = "src\Avatales.Infrastructure"

if (-not (Test-Path $projectPath)) {
    Write-Error "❌ Kann Avatales.Api Projekt nicht finden. Bitte führen Sie das Script aus dem Root-Verzeichnis aus."
    exit 1
}

Write-Host "📁 Projekt gefunden: $projectPath" -ForegroundColor Green

# Wechsle zum API-Projekt Verzeichnis
Set-Location $projectPath

Write-Host "🔧 Installiere erforderliche NuGet-Pakete..." -ForegroundColor Yellow

# Stelle sicher, dass alle erforderlichen Pakete installiert sind
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL

Write-Host "✅ NuGet-Pakete installiert" -ForegroundColor Green

# Lösche eventuelle vorhandene Migrations (für Clean Start)
if (Test-Path "..\Avatales.Infrastructure\Migrations") {
    Write-Host "🗑️ Lösche vorhandene Migrations..." -ForegroundColor Yellow
    Remove-Item "..\Avatales.Infrastructure\Migrations" -Recurse -Force
}

Write-Host "📝 Erstelle Initial Migration..." -ForegroundColor Yellow

# Erstelle die Migration
$migrationResult = dotnet ef migrations add InitialSchema --project "..\Avatales.Infrastructure" --startup-project . --output-dir "Migrations"

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Fehler beim Erstellen der Migration!"
    Set-Location $currentDir
    exit 1
}

Write-Host "✅ Migration erfolgreich erstellt" -ForegroundColor Green

Write-Host "🏗️ Führe Migration aus..." -ForegroundColor Yellow

# Führe die Migration aus
$updateResult = dotnet ef database update --project "..\Avatales.Infrastructure" --startup-project .

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Fehler beim Ausführen der Migration!"
    Set-Location $currentDir
    exit 1
}

Write-Host "✅ Datenbank erfolgreich aktualisiert!" -ForegroundColor Green

# Zurück zum ursprünglichen Verzeichnis
Set-Location $currentDir

Write-Host ""
Write-Host "🎉 MIGRATION ERFOLGREICH ABGESCHLOSSEN!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "✅ Datenbanktabellen erstellt:" -ForegroundColor White
Write-Host "   - Characters (Character DNA Templates)" -ForegroundColor Gray
Write-Host "   - CharacterInstances (Familie-spezifische Kopien)" -ForegroundColor Gray
Write-Host "   - CharacterMemories (AI Memory System)" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Sie können jetzt die API starten!" -ForegroundColor Cyan
Write-Host "   > cd src\Avatales.Api" -ForegroundColor Gray
Write-Host "   > dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 API wird verfügbar sein unter:" -ForegroundColor Cyan
Write-Host "   - https://localhost:5221" -ForegroundColor Gray
Write-Host "   - http://localhost:5220" -ForegroundColor Gray
Write-Host "   - Swagger UI: https://localhost:5221/swagger" -ForegroundColor Gray

# Optional: Zeige Migrations-Informationen
Write-Host ""
Write-Host "📊 Migration Details:" -ForegroundColor Yellow
dotnet ef migrations list --project $infrastructurePath --startup-project $projectPath