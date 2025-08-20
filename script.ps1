@echo off
echo ================================================
echo SOFORT-FIX: Namespace-Probleme beheben
echo ================================================
echo.

cd /d C:\MyProjects\Edory\src\Edory.Api

echo ❌ BUILD-FEHLER ERKANNT: Namespace-Probleme (Avatales statt Edory)
echo.
echo ⚠️ Sie müssen folgende 4 Dateien manuell ersetzen:
echo.
echo 1. src\Edory.Infrastructure\Data\EdoryDbContext.cs
echo    → Ersetzen mit "EdoryDbContext.cs (Komplett korrigiert)" Artefakt
echo.
echo 2. src\Edory.Infrastructure\Data\Configurations\CharacterMemoryConfiguration.cs
echo    → Ersetzen mit "CharacterMemoryConfiguration.cs (Korrigiert)" Artefakt
echo.
echo 3. src\Contexts\Character\Edory.Character.Domain\CharacterInstance.cs
echo    → Ersetzen mit "CharacterInstance.cs (Vereinfacht)" Artefakt  
echo.
echo 4. src\Edory.Infrastructure\Data\Configurations\CharacterInstanceConfiguration.cs
echo    → Ersetzen mit "CharacterInstanceConfiguration.cs (Vereinfacht)" Artefakt
echo.
echo ================================================
echo NACH DEM ERSETZEN DER DATEIEN:
echo ================================================
echo.
echo 1. Build testen:
echo    dotnet build
echo.
echo 2. Datenbank löschen:
echo    dotnet ef database drop --force --project ..\Edory.Infrastructure --startup-project .
echo.
echo 3. Migrations löschen:
echo    rmdir /s "..\Edory.Infrastructure\Migrations"
echo.
echo 4. Neue Migration:
echo    dotnet ef migrations add SimplifiedCharacterInstance --project ..\Edory.Infrastructure --startup-project .
echo.
echo 5. Datenbank erstellen:
echo    dotnet ef database update --project ..\Edory.Infrastructure --startup-project .
echo.
echo 6. API starten:
echo    dotnet run
echo.
echo ================================================
echo WICHTIG: Das Problem sind NAMESPACE-REFERENZEN
echo ================================================
echo.
echo Die Dateien enthalten noch "using Avatales.*" statt "using Edory.*"
echo Bitte ersetzen Sie alle 4 Dateien mit den korrigierten Versionen!
echo.
pause