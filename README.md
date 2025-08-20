# Edory - KI-gestützte Storytelling-Plattform

Edory ist eine innovative soziale Storytelling-Plattform, die künstliche Intelligenz nutzt, um personalisierte, interaktive Geschichten für Kinder und Familien zu generieren.

## 🎯 Kernfeatures

### 🎭 Persistente Charakter-Intelligenz
- **Hierarchisches Gedächtnissystem**: Akut-, Thematisches- und Persönlichkeits-Gedächtnis
- **Charakter-Evolution**: Eigenschaften entwickeln sich basierend auf Erfahrungen
- **DNA-System**: Jeder Charakter hat eine eindeutige "DNA" mit Basis-Eigenschaften

### 👨‍👩‍👧‍👦 Sozialer Charakter-Austausch
- Familien können Charaktere miteinander teilen
- Jede Familie erhält eine eigene Instanz des geteilten Charakters
- Separate Entwicklungsgeschichten pro Familie

### 🎓 Intelligenter Lernmodus
- Pädagogische Ziele nahtlos in Geschichten integriert
- Lernfortschritt-Tracking
- Anpassbare Schwierigkeitsstufen

## 🏗️ Architektur

### Modularer Monolith mit DDD & CQRS
```
📦 Edory
├── 🛡️ SharedKernel (DDD Base Classes, Value Objects)
├── 🎭 Character Context (Charakter-Management)
├── 🧠 Memory Context (Hierarchisches Gedächtnissystem)
├── 📚 Story Context (AI-Geschichtenerstellung)
├── 🎓 Learning Context (Pädagogisches System)
└── 🌐 API Layer (REST Controllers)
```

### Bounded Contexts

#### 🎭 Character Context
- **Character**: Basis-Template für Charaktere
- **CharacterInstance**: Spezifische Incarnation in einer Familie
- **CharacterDna**: Unveränderliche Basis-Eigenschaften
- **CharacterTraits**: Entwickelbare Eigenschaften (Mut, Kreativität, etc.)

#### 🧠 Memory Context (Kernstück!)
- **CharacterMemory**: Hierarchisches Gedächtnissystem
  - **Akut-Gedächtnis**: Letzte 50 detaillierte Fragmente (30 Tage)
  - **Thematisches Gedächtnis**: 100 wichtige Erfahrungen (1 Jahr)
  - **Persönlichkeits-Gedächtnis**: 25 prägende Erinnerungen (permanent)
- **MemoryFragment**: Einzelne Erinnerung mit emotionalem Kontext
- **EmotionalContext**: 8 Emotionen (Freude, Trauer, Angst, etc.)

#### 📚 Story Context
- **Story**: AI-generierte oder manuelle Geschichten
- **StoryConfiguration**: Genre, Länge, Zielgruppe, Lernziele
- **StoryChapter**: Mehrteilige Geschichten

#### 🎓 Learning Context
- **LearningObjective**: Definierte Lernziele
- **LearningCategory**: 15 Kategorien (Emotionale Entwicklung, Mathematik, etc.)
- **SkillLevel**: Schwierigkeitsstufen (Anfänger bis Experte)

## 🚀 Quick Start

### Voraussetzungen
- .NET 8 SDK
- Visual Studio 2022 oder VS Code

### Projekt starten
```bash
# Repository klonen (falls aus Git)
git clone <repository-url>
cd Edory

# Dependencies installieren
dotnet restore

# API starten
cd src/Edory.Api
dotnet run
```

### API testen
- **Swagger UI**: `https://localhost:7000` (automatisch geöffnet)
- **Health Check**: `https://localhost:7000/health`

## 🔧 API Endpoints

### 🎭 Charaktere
```http
POST   /api/characters              # Neuen Charakter erstellen
GET    /api/characters/{id}         # Charakter abrufen
GET    /api/characters/public       # Öffentliche Charaktere auflisten
```

### 📚 Geschichten
```http
POST   /api/stories/generate        # Geschichte generieren
GET    /api/stories/{id}            # Geschichte abrufen
GET    /api/stories/character/{id}  # Geschichten eines Charakters
```

### 🎓 Lernziele
```http
POST   /api/learning/objectives           # Lernziel erstellen
GET    /api/learning/objectives/{id}      # Lernziel abrufen
GET    /api/learning/objectives/family/{id} # Familien-Lernziele
POST   /api/learning/objectives/{id}/generate-story # Lerngeschichte
```

## 📋 Beispiel-Requests

### Charakter erstellen
```json
POST /api/characters
{
  "name": "Luna die Entdeckerin",
  "description": "Eine neugierige Katze, die gerne Abenteuer erlebt",
  "appearance": "Weiße Katze mit blauen Augen",
  "personality": "Neugierig und mutig",
  "familyId": "12345678-1234-1234-1234-123456789012",
  "minAge": 4,
  "maxAge": 10,
  "courage": 70,
  "creativity": 80,
  "curiosity": 90,
  "helpfulness": 75
}
```

### Geschichte generieren
```json
POST /api/stories/generate
{
  "characterInstanceId": "12345678-1234-1234-1234-123456789012",
  "familyId": "12345678-1234-1234-1234-123456789012",
  "characterName": "Luna",
  "genre": "Adventure",
  "length": "Medium",
  "targetAge": 6,
  "keywords": ["Freundschaft", "Mut", "Magie"],
  "setting": "Verzauberter Wald",
  "mood": "Aufregend",
  "includeMoralLesson": true,
  "learningObjective": "Mut in neuen Situationen zeigen",
  "creativityLevel": 7
}
```

### Lernziel erstellen
```json
POST /api/learning/objectives
{
  "title": "Mut entwickeln",
  "description": "Lernen, mutig zu sein und neue Herausforderungen anzunehmen",
  "category": "EmotionalDevelopment",
  "level": "Basic",
  "targetAge": 6,
  "familyId": "12345678-1234-1234-1234-123456789012",
  "priority": 8,
  "keywords": ["mut", "herausforderung", "selbstvertrauen"],
  "successCriteria": [
    "Zeigt Initiative bei neuen Aktivitäten",
    "Überwindet kleine Ängste"
  ]
}
```

## 🎯 MVP Status

### ✅ Implementiert
- ✅ DDD/CQRS Architektur-Grundlage
- ✅ Character Domain mit DNA-System
- ✅ Memory Domain mit hierarchischem Gedächtnis
- ✅ Story Domain mit Konfiguration
- ✅ Learning Domain mit Lernzielen
- ✅ REST API mit Swagger-Dokumentation
- ✅ Mock-Responses für alle Endpoints

### 🔄 Nächste Schritte (für Vollversion)
- [ ] Persistierung (Entity Framework Core)
- [ ] AI-Integration (GPT-5 Nano, Runware)
- [ ] Application Services & CQRS Handlers
- [ ] Event Sourcing für Memory Context
- [ ] Domain Event Handling
- [ ] Authentication & Authorization
- [ ] Familienmanagement
- [ ] Repository-Implementierungen
- [ ] Unit & Integration Tests
- [ ] Flutter Frontend

## 🔮 KI-Integration (Geplant)

### AI Services
- **Story Generation**: GPT-5 Nano ($0.05/1M input, $0.40/1M output)
- **Image Generation**: Runware ($0.0006/Bild)
- **Memory Consolidation**: Automatische Wichtigkeitsbewertung
- **Learning Optimization**: Adaptive Schwierigkeitsanpassung

### Kostenoptimierung
- Intelligentes Caching für Charakter-Kontexte
- Prompt-Optimierung für Token-Effizienz
- Batch-Processing für Memory-Konsolidierung

## 📊 Geschäftsmodell

### Abonnement-Stufen
- **Starter**: €4.99/Monat (10 Geschichten)
- **Familie**: €12.99/Monat (30 Geschichten, voller sozialer Zugang)
- **Premium**: €24.99/Monat (unbegrenzt, AR-Integration, Voice-Cloning)
- **Erwachsenen-Modus**: €19.99/Monat (therapeutische Geschichten)

### Projektion (10.000 Nutzer)
- **Umsatz**: €142.890/Monat
- **KI-Kosten**: €3.000/Monat
- **Gewinnmarge**: 83%

## 🛡️ Sicherheit & Compliance

- DSGVO-konform
- Kinderdatenschutz
- Automatische Content-Moderation
- Elterliche Kontrollen

## 👥 Entwicklung

Dieses MVP demonstriert die Kernarchitektur und -funktionalitäten von Edory. 
Für die Vollversion sind zusätzliche Infrastructure-, Application- und Integration-Schichten erforderlich.

### Architektur-Prinzipien
- **Domain-Driven Design**: Fachlogik im Zentrum
- **CQRS**: Getrennte Lese-/Schreibmodelle für komplexe Domänen
- **Event Sourcing**: Für Memory Context (Charakter-Entwicklung)
- **Hexagonale Architektur**: Entkoppelte, testbare Services

---

**Edory** - Wo Geschichten lebendig werden und Charaktere wachsen! 🌟
