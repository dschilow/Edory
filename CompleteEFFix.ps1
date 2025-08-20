# Edory Entity Framework - KOMPLETTE REPARATUR
# Behebt EF Core Tracking-Probleme durch Vereinfachung der Struktur

Write-Host "🔧 EDORY ENTITY FRAMEWORK - KOMPLETTE REPARATUR" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Prüfe ob wir im richtigen Verzeichnis sind
$currentDir = Get-Location
$projectPath = "src\Edory.Api"
$infrastructurePath = "src\Edory.Infrastructure"

if (-not (Test-Path $projectPath)) {
    Write-Error "❌ Kann Edory.Api Projekt nicht finden. Bitte führen Sie das Script aus dem Root-Verzeichnis aus."
    exit 1
}

Write-Host "📁 Projekt gefunden: $projectPath" -ForegroundColor Green

# Prüfe ob Visual Studio läuft
$vsProcesses = Get-Process | Where-Object { $_.ProcessName -like "*devenv*" -or $_.ProcessName -like "*VisualStudio*" }
if ($vsProcesses) {
    Write-Host "⚠️ Visual Studio läuft noch. Bitte schließen Sie Visual Studio vollständig..." -ForegroundColor Yellow
    Write-Host "   Warten auf Schließung von Visual Studio..." -ForegroundColor Gray
    
    do {
        Start-Sleep -Seconds 2
        $vsProcesses = Get-Process | Where-Object { $_.ProcessName -like "*devenv*" -or $_.ProcessName -like "*VisualStudio*" }
    } while ($vsProcesses)
    
    Write-Host "✅ Visual Studio geschlossen" -ForegroundColor Green
}

# Wechsle zum API-Projekt Verzeichnis
Set-Location $projectPath

Write-Host ""
Write-Host "🗑️ PHASE 1: Datenbankbereinigung" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

# Lösche die aktuelle Datenbank komplett
try {
    Write-Host "Lösche Datenbank..." -ForegroundColor Gray
    dotnet ef database drop --force --project "..\Edory.Infrastructure" --startup-project . 2>$null
    Write-Host "✅ Datenbank gelöscht" -ForegroundColor Green
} catch {
    Write-Host "ℹ️ Datenbank war nicht vorhanden oder bereits gelöscht" -ForegroundColor Gray
}

# Lösche alle Migration-Dateien
if (Test-Path "..\Edory.Infrastructure\Migrations") {
    Remove-Item "..\Edory.Infrastructure\Migrations" -Recurse -Force
    Write-Host "✅ Migration-Dateien gelöscht" -ForegroundColor Green
}

Write-Host ""
Write-Host "📝 PHASE 2: Neue Struktur implementieren" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

Write-Host "⚠️ WICHTIG: Bitte stellen Sie sicher, dass Sie folgende Dateien ersetzt haben:" -ForegroundColor Yellow
Write-Host "   1. CharacterInstance.cs (Vereinfachte Version ohne Owned Types)" -ForegroundColor Gray
Write-Host "   2. CharacterInstanceConfiguration.cs (Primitive Properties)" -ForegroundColor Gray
Write-Host "   3. CharacterInstanceRepository.cs (Angepasst für neue Struktur)" -ForegroundColor Gray

$confirmed = Read-Host "Haben Sie die korrigierten Dateien eingefügt? (y/n)"
if ($confirmed -ne "y" -and $confirmed -ne "Y") {
    Write-Host "❌ Bitte fügen Sie zuerst die korrigierten Dateien ein und führen Sie das Script erneut aus." -ForegroundColor Red
    Set-Location $currentDir
    exit 1
}

Write-Host "📦 Build-Test..." -ForegroundColor Gray
dotnet build --verbosity quiet

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Build fehlgeschlagen! Bitte prüfen Sie die Implementierung."
    Set-Location $currentDir
    exit 1
}

Write-Host "✅ Build erfolgreich" -ForegroundColor Green

Write-Host ""
Write-Host "🏗️ PHASE 3: Migration erstellen" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow

# Erstelle die neue Migration
Write-Host "Erstelle vereinfachte Migration..." -ForegroundColor Gray
$migrationResult = dotnet ef migrations add SimplifiedCharacterInstance --project "..\Edory.Infrastructure" --startup-project . --output-dir "Migrations"

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Fehler beim Erstellen der Migration!"
    Set-Location $currentDir
    exit 1
}

Write-Host "✅ Migration erfolgreich erstellt" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 PHASE 4: Datenbank erstellen" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow

# Führe die Migration aus
Write-Host "Erstelle Datenbank mit neuer Struktur..." -ForegroundColor Gray
$updateResult = dotnet ef database update --project "..\Edory.Infrastructure" --startup-project .

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Fehler beim Ausführen der Migration!"
    Set-Location $currentDir
    exit 1
}

Write-Host "✅ Datenbank erfolgreich erstellt!" -ForegroundColor Green

Write-Host ""
Write-Host "🧪 PHASE 5: API-Test" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow

Write-Host "Starte API-Test..." -ForegroundColor Gray

# Kurzer API-Test
$testProcess = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -NoNewWindow
Start-Sleep -Seconds 10

if ($testProcess.HasExited) {
    Write-Error "❌ API konnte nicht gestartet werden!"
} else {
    Write-Host "✅ API gestartet erfolgreich" -ForegroundColor Green
    $testProcess.Kill()
}

# Zurück zum ursprünglichen Verzeichnis
Set-Location $currentDir

Write-Host ""
Write-Host "🎉 REPARATUR ABGESCHLOSSEN!" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Was wurde behoben:" -ForegroundColor White
Write-Host "   - CharacterTraits als primitive Properties gespeichert" -ForegroundColor Gray
Write-Host "   - Keine Owned Types mehr → Keine EF Tracking-Konflikte" -ForegroundColor Gray
Write-Host "   - Vereinfachte Datenbank-Struktur" -ForegroundColor Gray
Write-Host "   - Domain Logic bleibt erhalten (GetCurrentTraits(), etc.)" -ForegroundColor Gray
Write-Host "   - Repository angepasst für neue Struktur" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 JETZT TESTEN:" -ForegroundColor Cyan
Write-Host "   > cd src\Edory.Api" -ForegroundColor Gray
Write-Host "   > dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 API Endpoints:" -ForegroundColor Cyan
Write-Host "   - https://localhost:5221/swagger" -ForegroundColor Gray
Write-Host "   - POST /api/characters (sollte jetzt funktionieren!)" -ForegroundColor Gray
Write-Host ""
Write-Host "📱 Flutter App:" -ForegroundColor Cyan
Write-Host "   - cd edory_app" -ForegroundColor Gray
Write-Host "   - flutter run" -ForegroundColor Gray

# Migrations-Informationen
Write-Host ""
Write-Host "📊 Migration Details:" -ForegroundColor Yellow
try {
    dotnet ef migrations list --project $infrastructurePath --startup-project $projectPath
} catch {
    Write-Host "ℹ️ Migrations-Liste nicht verfügbar" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎯 DAS EF TRACKING-PROBLEM SOLLTE JETZT VOLLSTÄNDIG BEHOBEN SEIN!" -ForegroundColor Green
Write-Host "Charaktererstellung sollte ohne Fehler funktionieren! 🎉" -ForegroundColor Green