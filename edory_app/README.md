# 📱 Edory Flutter App

Eine professionelle Flutter-App für die Edory-Plattform mit Clean Architecture, modernem Design und vollständiger Backend-Integration.

## ✨ Features

### 🏗️ **Clean Architecture**
- **Domain Layer**: Entities, Use Cases, Repository Interfaces
- **Data Layer**: API Services, Repository Implementations, Models
- **Presentation Layer**: Pages, Widgets, State Management

### 🎨 **Modern UI/UX**
- **Material Design 3** mit Pastel-Farbschema
- **Responsive Design** für alle Bildschirmgrößen
- **Accessibility Support** für Barrierefreiheit
- **Dark/Light Theme** Unterstützung
- **Animate-Bibliothek** für flüssige Animationen

### 🛠️ **State Management**
- **Riverpod** für reaktive State-Verwaltung
- **MVVM Pattern** für saubere Architektur
- **Error Handling** und Loading States

### 🧭 **Navigation**
- **GoRouter** für type-safe Navigation
- **Deep Linking** Support
- **Nested Navigation** mit Bottom Navigation

### 🌐 **Backend Integration**
- **REST API** mit Dio und Retrofit
- **Repository Pattern** für Datenabstraktion
- **Error Handling** und Offline Support

## 📱 Screenshots

### Home Screen
- Personalisierte Begrüßung basierend auf Tageszeit
- Hero Card mit CTA für Geschichtenerstellung
- Wöchentliche Fortschritts-Statistiken
- Charakter-Sammlung Preview

### Characters Screen
- Grid-Layout für Charaktere
- Interaktive Character Cards mit Animations
- Statistik-Übersicht (Geschichten, Level, Eigenschaften)
- Add Character Card für neue Charaktere

### Navigation
- Custom Bottom Navigation mit Glasmorphism-Effekt
- Aktive State-Anzeige
- Smooth Transitions zwischen Screens

## 🎯 Design-System

### Farb-Palette
```dart
// Primary Colors
Color primaryBlue = Color(0xFF007AFF);
Color primaryPurple = Color(0xFF5856D6);

// Pastel Accents
Color pastelRed = Color(0xFFFF6B6B);
Color pastelOrange = Color(0xFFFFCC02);
Color pastelGreen = Color(0xFF34C759);
Color pastelBlue = Color(0xFF5AC8FA);
Color pastelPurple = Color(0xFFAF52DE);

// Surface Colors
Color lightSurface = Color(0xFFF5F7FA);
Color cardBackground = Color(0xFFFFFFFF);
```

### Typography
- **Font Family**: Inter (Google Fonts)
- **Font Weights**: 300-900
- **Typographic Scale**: Material Design 3 konform

### Spacing & Layout
- **Basis-Einheit**: 8px
- **Padding**: 16px, 20px, 24px
- **Margins**: 8px, 16px, 20px
- **Border Radius**: 12px, 16px, 20px, 24px

## 🏗️ Projektstruktur

```
lib/
├── core/                          # Kern-Infrastruktur
│   ├── constants/                 # API Constants, App Constants
│   ├── error/                     # Error Handling, Failures
│   ├── providers/                 # Global Providers
│   ├── router/                    # App Router (GoRouter)
│   ├── theme/                     # App Theme, Colors, Typography
│   └── utils/                     # Utilities, Extensions
├── features/                      # Feature-basierte Module
│   ├── characters/               # Character Management
│   │   ├── domain/              # Entities, Use Cases, Repositories
│   │   ├── data/                # Models, Data Sources, Repository Impl
│   │   └── presentation/        # Pages, Widgets, Providers
│   ├── stories/                 # Story Management
│   ├── learning/                # Learning Management
│   ├── community/               # Community Features
│   ├── home/                    # Home Dashboard
│   └── profile/                 # User Profile
├── shared/                       # Gemeinsame Komponenten
│   └── presentation/            # Shared Widgets, Pages
└── main.dart                    # App Entry Point
```

## 🚀 Getting Started

### Voraussetzungen
- Flutter SDK >= 3.10.0
- Dart >= 3.0.0

### Installation

1. **Dependencies installieren**
```bash
cd edory_app
flutter pub get
```

2. **Code Generation ausführen**
```bash
flutter packages pub run build_runner build
```

3. **App starten**
```bash
flutter run
```

## 📦 Abhängigkeiten

### Core Dependencies
- `flutter_riverpod` - State Management
- `go_router` - Navigation
- `dio` & `retrofit` - HTTP Client & API
- `json_annotation` - JSON Serialization

### UI/UX Dependencies
- `flutter_animate` - Animations
- `cached_network_image` - Image Caching
- `flutter_svg` - SVG Support

### Utility Dependencies
- `equatable` - Value Equality
- `dartz` - Functional Programming
- `shared_preferences` - Local Storage
- `hive` - Local Database

### Development Dependencies
- `build_runner` - Code Generation
- `retrofit_generator` - API Client Generation
- `json_serializable` - JSON Serialization
- `flutter_lints` - Linting Rules

## 🎨 UI Komponenten

### Custom Widgets

#### `GradientCard`
```dart
GradientCard(
  gradient: AppTheme.primaryGradient,
  child: YourContent(),
)
```

#### `CharacterCard`
```dart
CharacterCard(
  character: character,
  onTap: () => navigate(),
  isSelectable: true,
)
```

#### `StatsRow`
```dart
StatsRow(
  stats: [
    StatData(
      icon: '🔥',
      value: '47',
      label: 'Geschichten',
      gradient: AppTheme.redGradient,
    ),
  ],
)
```

#### `HeroCard`
```dart
HeroCard(
  title: 'Erschaffe magische Welten',
  subtitle: 'Personalisierte KI-Geschichten...',
  buttonText: 'Neue Geschichte erstellen',
  onPressed: () => createStory(),
)
```

## 🔗 Backend Integration

### API Endpoints
```dart
// Characters
GET    /api/characters              # Alle Charaktere
GET    /api/characters/public       # Öffentliche Charaktere
POST   /api/characters              # Charakter erstellen
GET    /api/characters/{id}         # Charakter Details

// Stories
POST   /api/stories/generate        # Geschichte generieren
GET    /api/stories/{id}            # Geschichte Details

// Learning
GET    /api/learning/objectives     # Lernziele
POST   /api/learning/objectives     # Lernziel erstellen
```

### Repository Pattern
```dart
class CharactersRepositoryImpl implements CharactersRepository {
  ResultFuture<List<Character>> getCharacters() async {
    try {
      final result = await _remoteDataSource.getCharacters();
      return Right(result.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

## 🎯 State Management

### Riverpod Providers
```dart
// Characters Provider
final charactersProvider = StateNotifierProvider<CharactersNotifier, AsyncValue<List<Character>>>(
  (ref) => CharactersNotifier(ref.watch(getCharactersProvider)),
);

// Usage in Widget
final charactersState = ref.watch(charactersProvider);
charactersState.when(
  data: (characters) => CharactersList(characters),
  loading: () => LoadingWidget(),
  error: (error, _) => ErrorWidget(error),
);
```

## 🎨 Theming

### App Theme
```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF007AFF),
      secondary: Color(0xFF5856D6),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        fontFamily: 'Inter',
      ),
    ),
  );
}
```

## 🌐 Internationalisierung

### Unterstützte Sprachen
- 🇩🇪 Deutsch (Standard)
- 🇺🇸 Englisch (Geplant)

## 📱 Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- 🔄 **Web** (Geplant)
- 🔄 **Desktop** (Geplant)

## 🚀 Build & Deploy

### Debug Build
```bash
flutter run --debug
```

### Release Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔧 Development

### Code Generation
```bash
# Einmalig
flutter packages pub run build_runner build

# Watch Mode
flutter packages pub run build_runner watch
```

### Linting
```bash
flutter analyze
```

### Testing
```bash
flutter test
```

## 📈 Performance

### Optimierungen
- **Lazy Loading** für Listen
- **Image Caching** für bessere Performance
- **State Management** für minimale Rebuilds
- **Bundle Splitting** für kleinere App-Größe

### Metrics
- **App Start Time**: < 2 Sekunden
- **Page Transitions**: 60 FPS
- **Memory Usage**: Optimiert für Mobile

## 🔮 Roadmap

### Version 2.0
- [ ] Story Creation UI
- [ ] Character Trait Editor
- [ ] Learning Progress Dashboard
- [ ] Community Features
- [ ] Voice Integration
- [ ] AR Character Viewer

### Version 3.0
- [ ] Offline Mode
- [ ] Advanced Animations
- [ ] Multiple Language Support
- [ ] Tablet Optimierung
- [ ] Widget Extensions

## 🤝 Contributing

1. **Architecture**: Befolge Clean Architecture Prinzipien
2. **Code Style**: Flutter/Dart Linting Rules
3. **UI/UX**: Material Design 3 Guidelines
4. **Testing**: Unit Tests für Business Logic
5. **Documentation**: Kommentiere komplexe Logik

## 📄 License

Copyright © 2024 Edory. All rights reserved.

---

**Edory Flutter App** - Wo Geschichten lebendig werden! 🌟📱
