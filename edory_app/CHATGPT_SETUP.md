# 🤖 ChatGPT API Setup für Edory

## 🚀 OpenAI API Key einrichten

### Schritt 1: OpenAI Account erstellen
1. Gehen Sie zu: https://platform.openai.com/
2. **Account erstellen** oder **Anmelden**
3. **API Keys** → **Create new secret key**
4. **Kopieren Sie den API Key** (beginnt mit `sk-...`)

### Schritt 2: API Key in der App konfigurieren

**Option A: Direkt in Code (nur für Testing)**
```dart
// lib/core/services/openai_service.dart
static const String _apiKey = 'sk-your-actual-api-key-here';
```

**Option B: Environment Variables (Empfohlen)**
```dart
static final String _apiKey = const String.fromEnvironment('OPENAI_API_KEY');
```

### Schritt 3: Flutter App mit API Key starten
```bash
flutter run --dart-define=OPENAI_API_KEY=sk-your-actual-api-key-here
```

## 💰 Kosten-Übersicht

### GPT-4 Preise (Stand 2024):
- **Input**: $10.00 / 1M tokens
- **Output**: $30.00 / 1M tokens

### Beispiel-Kosten für Geschichten:
- **Kurze Geschichte** (500 Wörter): ~$0.02 - $0.05
- **Mittlere Geschichte** (1000 Wörter): ~$0.05 - $0.10
- **Lange Geschichte** (2000 Wörter): ~$0.10 - $0.20

### Kostenkontrolle:
1. **Usage Limits** in OpenAI Dashboard setzen
2. **Billing Alerts** aktivieren
3. **Token-Limits** in der App konfigurieren

## 🔧 API Features in Edory

### 1. **Story Generation**
```dart
final story = await openAIService.generateStory(
  characterName: 'Luna die Entdeckerin',
  characterDescription: 'Eine mutige Abenteurerin...',
  prompt: 'Ein Unterwasserabenteuer mit Delfinen',
  targetAge: 8,
  genre: 'Abenteuer',
  length: 'Mittel',
  learningObjectives: ['Mut entwickeln', 'Empathie fördern'],
);
```

### 2. **Character Generation** (Geplant)
```dart
final character = await openAIService.generateCharacter(
  basicDescription: 'Ein magischer Drache der Geschichten erzählt',
  targetAge: 6,
);
```

### 3. **Story Enhancement** (Geplant)
- **Illustration Prompts** für DALL-E
- **Interactive Elements** hinzufügen
- **Educational Content** integrieren

## 🛡️ Sicherheit & Best Practices

### API Key Sicherheit:
- ✅ **Niemals** API Keys in Git committen
- ✅ **Environment Variables** verwenden
- ✅ **Server-side Proxy** für Production
- ✅ **Rate Limiting** implementieren

### Content Filtering:
- ✅ **Family-friendly** Content sicherstellen
- ✅ **Age-appropriate** Language
- ✅ **Educational Value** priorisieren

## 🔄 Alternative AI Services

Falls OpenAI nicht verfügbar:

### 1. **Google Gemini API**
- Günstiger als GPT-4
- Gute Deutsch-Unterstützung
- Familie-freundliche Inhalte

### 2. **Anthropic Claude**
- Sehr sicher für Kinder-Content
- Exzellente Storytelling-Fähigkeiten
- Ethische KI-Grundsätze

### 3. **Local AI Models**
- **Ollama** mit Llama 3.1
- **Offline verfügbar**
- **Keine API-Kosten**

## 📊 Testing ohne API Key

Für lokale Tests ohne echte API:

```dart
// Mock-Service aktivieren
final useRealAPI = false;

if (useRealAPI) {
  final story = await openAIService.generateStory(...);
} else {
  final story = generateMockStory(...); // Bereits implementiert
}
```

## 🚀 Production Deployment

### Server-side Proxy (Empfohlen):
```
Flutter App → Ihr Backend → OpenAI API
```

**Vorteile:**
- ✅ API Key bleibt geheim
- ✅ Content-Filtering möglich
- ✅ Kosten-Kontrolle
- ✅ Analytics & Logging

### Backend Integration:
```csharp
// In Ihrem .NET Backend
public async Task<string> GenerateStory(StoryRequest request)
{
    var client = new OpenAIClient(apiKey);
    var response = await client.ChatCompletions.CreateAsync(...);
    return response.Content;
}
```

## 🎯 Nächste Schritte

1. **✅ OpenAI API Key besorgen**
2. **✅ API Key in App konfigurieren**
3. **✅ Erste Geschichte generieren**
4. **🔄 Content-Filter implementieren**
5. **🔄 Kosten-Monitoring einrichten**
6. **🔄 Production-Proxy entwickeln**

## 📞 Support

Bei Problemen mit der OpenAI Integration:

1. **OpenAI Status**: https://status.openai.com/
2. **API Documentation**: https://platform.openai.com/docs
3. **Rate Limits prüfen**: OpenAI Dashboard → Usage
4. **Error Logs**: Flutter Console für Details

---

**🌟 Mit ChatGPT wird Edory zu einer magischen Storytelling-Plattform!** 📚✨
