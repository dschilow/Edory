# 🐳 PostgreSQL + Docker Setup für Edory

## 📋 Schritt-für-Schritt Anleitung für Anfänger

### **Was ist Docker?**
Docker ist wie ein "Container" für Programme. Es packt alle benötigten Teile (Datenbank, Code, etc.) zusammen, damit alles überall gleich funktioniert.

---

## 🛠️ **1. Docker installieren**

### **Windows:**
1. Gehen Sie zu: https://www.docker.com/products/docker-desktop/
2. **"Download Docker Desktop"** → **Windows**
3. **Installieren** und **Computer neu starten**
4. **Docker Desktop starten**

### **Prüfen ob Docker funktioniert:**
```powershell
docker --version
# Sollte zeigen: Docker version 24.x.x
```

---

## 🗄️ **2. PostgreSQL mit Docker starten**

### **Erstelle Docker Compose Datei:**

```yaml
# C:\MyProjects\Edory\docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: edory_postgres
    environment:
      POSTGRES_DB: edory
      POSTGRES_USER: edory_user
      POSTGRES_PASSWORD: edory_password123
      POSTGRES_HOST_AUTH_METHOD: trust
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sql/init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped

  pgadmin:
    image: dpage/pgadmin4
    container_name: edory_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@edory.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "8080:80"
    depends_on:
      - postgres
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local
```

### **PostgreSQL starten:**
```powershell
cd C:\MyProjects\Edory
docker-compose up -d
```

**Das war's! PostgreSQL läuft jetzt! 🎉**

---

## 📊 **3. Datenbank-Schema erstellen**

### **Erstelle SQL-Initialisierung:**

```sql
-- C:\MyProjects\Edory\sql\init.sql
-- Edory Database Schema

-- Familien/Nutzer
CREATE TABLE Families (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    SubscriptionLevel VARCHAR(20) DEFAULT 'Free',
    IsActive BOOLEAN DEFAULT true
);

-- Charakter DNA (Basis-Template)
CREATE TABLE CharacterDnas (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Name VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Appearance TEXT NOT NULL,
    Personality TEXT NOT NULL,
    BaseCourage INTEGER DEFAULT 50,
    BaseCreativity INTEGER DEFAULT 50,
    BaseHelpfulness INTEGER DEFAULT 50,
    BaseHumor INTEGER DEFAULT 50,
    BaseWisdom INTEGER DEFAULT 50,
    BaseCuriosity INTEGER DEFAULT 50,
    BaseEmpathy INTEGER DEFAULT 50,
    BasePersistence INTEGER DEFAULT 50,
    CreatorFamilyId UUID REFERENCES Families(Id),
    IsPublic BOOLEAN DEFAULT false,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Charakter-Instanzen (pro Familie)
CREATE TABLE CharacterInstances (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    CharacterDnaId UUID REFERENCES CharacterDnas(Id),
    FamilyId UUID REFERENCES Families(Id),
    CustomName VARCHAR(100),
    CurrentCourage INTEGER DEFAULT 50,
    CurrentCreativity INTEGER DEFAULT 50,
    CurrentHelpfulness INTEGER DEFAULT 50,
    CurrentHumor INTEGER DEFAULT 50,
    CurrentWisdom INTEGER DEFAULT 50,
    CurrentCuriosity INTEGER DEFAULT 50,
    CurrentEmpathy INTEGER DEFAULT 50,
    CurrentPersistence INTEGER DEFAULT 50,
    Level INTEGER DEFAULT 1,
    ExperienceCount INTEGER DEFAULT 0,
    LastInteractionAt TIMESTAMP WITH TIME ZONE,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Charakter-Gedächtnis (Memory System)
CREATE TABLE CharacterMemories (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    CharacterInstanceId UUID REFERENCES CharacterInstances(Id),
    MemoryType VARCHAR(20) CHECK (MemoryType IN ('Acute', 'Thematic', 'Personality')),
    Content TEXT NOT NULL,
    EmotionalContext VARCHAR(20),
    Importance INTEGER CHECK (Importance BETWEEN 1 AND 10),
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ConsolidatedAt TIMESTAMP WITH TIME ZONE,
    IsActive BOOLEAN DEFAULT true
);

-- Geschichten
CREATE TABLE Stories (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Title VARCHAR(200) NOT NULL,
    Content TEXT NOT NULL,
    CharacterInstanceId UUID REFERENCES CharacterInstances(Id),
    FamilyId UUID REFERENCES Families(Id),
    Genre VARCHAR(50) NOT NULL,
    TargetAge INTEGER NOT NULL,
    Length VARCHAR(20) NOT NULL,
    LearningObjectives TEXT[],
    IsGenerated BOOLEAN DEFAULT true,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ReadCount INTEGER DEFAULT 0,
    LikeCount INTEGER DEFAULT 0
);

-- Lernziele
CREATE TABLE LearningObjectives (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Category VARCHAR(50) NOT NULL,
    TargetAgeMin INTEGER NOT NULL,
    TargetAgeMax INTEGER NOT NULL,
    Keywords TEXT[],
    SuccessCriteria TEXT[],
    Priority INTEGER DEFAULT 5,
    IsActive BOOLEAN DEFAULT true,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Charakter-Interaktionen (für Experience/Trait Updates)
CREATE TABLE CharacterInteractions (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    CharacterInstanceId UUID REFERENCES CharacterInstances(Id),
    StoryId UUID REFERENCES Stories(Id),
    InteractionType VARCHAR(50) NOT NULL,
    TraitChanges JSONB,
    MemoryFragments TEXT[],
    Timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indizes für Performance
CREATE INDEX idx_character_instances_family ON CharacterInstances(FamilyId);
CREATE INDEX idx_character_memories_instance ON CharacterMemories(CharacterInstanceId);
CREATE INDEX idx_stories_family ON Stories(FamilyId);
CREATE INDEX idx_stories_character ON Stories(CharacterInstanceId);
CREATE INDEX idx_character_interactions_instance ON CharacterInteractions(CharacterInstanceId);

-- Beispiel-Daten einfügen
INSERT INTO Families (Name, Email, SubscriptionLevel) VALUES 
('Familie Schmidt', 'schmidt@example.com', 'Premium'),
('Familie Müller', 'mueller@example.com', 'Family');

-- Beispiel-Lernziele
INSERT INTO LearningObjectives (Name, Description, Category, TargetAgeMin, TargetAgeMax, Keywords) VALUES 
('Mut entwickeln', 'Hilft Kindern dabei, mutige Entscheidungen zu treffen', 'Persönlichkeit', 4, 12, ARRAY['mut', 'tapferkeit', 'herausforderung']),
('Vokabular erweitern', 'Erweitert den Wortschatz spielerisch', 'Sprache', 3, 10, ARRAY['wörter', 'sprache', 'kommunikation']),
('Empathie fördern', 'Entwickelt Mitgefühl und Verständnis für andere', 'Sozial', 4, 12, ARRAY['gefühle', 'mitgefühl', 'freundschaft']);
```

---

## 🔧 **4. .NET Backend für PostgreSQL konfigurieren**

### **NuGet Packages installieren:**
```powershell
cd C:\MyProjects\Edory\src\Edory.Api
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
```

### **Connection String konfigurieren:**
```json
// appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=edory;Username=edory_user;Password=edory_password123"
  }
}
```

### **DbContext erstellen:**
```csharp
// src/Edory.Infrastructure/Data/EdoryDbContext.cs
public class EdoryDbContext : DbContext
{
    public EdoryDbContext(DbContextOptions<EdoryDbContext> options) : base(options) { }

    public DbSet<Family> Families { get; set; }
    public DbSet<CharacterDna> CharacterDnas { get; set; }
    public DbSet<CharacterInstance> CharacterInstances { get; set; }
    public DbSet<CharacterMemory> CharacterMemories { get; set; }
    public DbSet<Story> Stories { get; set; }
    public DbSet<LearningObjective> LearningObjectives { get; set; }
}
```

---

## 🌐 **5. Zugriff auf die Datenbank**

### **PostgreSQL Web-Interface (pgAdmin):**
- **URL**: http://localhost:8080
- **Email**: admin@edory.com  
- **Passwort**: admin123

### **Direkte Verbindung:**
- **Host**: localhost
- **Port**: 5432
- **Database**: edory
- **Username**: edory_user
- **Password**: edory_password123

---

## 📱 **6. Flutter App mit PostgreSQL verbinden**

Die Flutter-App kommuniziert über das .NET Backend mit PostgreSQL:

```
Flutter App → HTTP Requests → .NET API → PostgreSQL
```

**Kein direkter Zugriff von Flutter zu PostgreSQL!**

---

## 🛠️ **7. Nützliche Docker-Befehle**

### **Container verwalten:**
```powershell
# Alle Container starten
docker-compose up -d

# Container stoppen
docker-compose down

# Container neustarten
docker-compose restart

# Container Status prüfen
docker-compose ps

# Logs anzeigen
docker-compose logs postgres
```

### **Datenbank zurücksetzen:**
```powershell
# Container und Daten löschen
docker-compose down -v

# Neu starten (mit frischer DB)
docker-compose up -d
```

---

## 🎯 **8. Was Sie jetzt haben:**

✅ **PostgreSQL-Datenbank** läuft in Docker  
✅ **pgAdmin Web-Interface** für Verwaltung  
✅ **Vollständiges Schema** für alle Edory-Features  
✅ **Beispiel-Daten** zum Testen  
✅ **Connection Strings** für .NET Backend  
✅ **Memory System** für persistente Charaktere  

---

## 🚀 **9. Nächste Schritte:**

1. **✅ Docker Container starten**
2. **🔄 .NET Backend verbinden**  
3. **📱 Flutter App testen**
4. **💾 Daten speichern prüfen**
5. **🧠 Memory System testen**

---

## 🆘 **Hilfe bei Problemen:**

### **Docker startet nicht:**
```powershell
# Docker Service neu starten
# Windows: Docker Desktop neu starten
```

### **Port bereits belegt:**
```powershell
# Andere PostgreSQL-Instanzen stoppen
net stop postgresql-x64-15
```

### **Container läuft nicht:**
```powershell
# Container Status prüfen
docker ps -a

# Logs für Fehlerdiagnose
docker logs edory_postgres
```

---

**🎉 Herzlichen Glückwunsch! PostgreSQL läuft jetzt mit Docker und ist bereit für Edory!** 🐳🗄️
