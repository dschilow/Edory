// lib/features/characters/data/datasources/characters_mock_data_source.dart
import '../models/character_model.dart';
import '../models/character_traits_model.dart';

class CharactersMockDataSource {
  static List<CharacterModel> getMockCharacters() {
    return [
      CharacterModel(
        id: '1',
        name: 'Luna die Entdeckerin',
        description: 'Eine mutige Abenteurerin, die neue Welten erkundet',
        appearance: 'Lange braune Haare, grüne Augen, Entdeckerausrüstung',
        personality: 'Neugierig, mutig und hilfsbereit',
        traits: const CharacterTraitsModel(
          courage: 85,
          creativity: 70,
          helpfulness: 80,
          humor: 60,
          wisdom: 65,
          curiosity: 95,
          empathy: 75,
          persistence: 80,
        ),
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        adoptionCount: 12,
        readCount: 45,
        lastInteractionAt: DateTime.now().subtract(const Duration(hours: 2)),
        level: 8,
        experienceCount: 35,
      ),
      CharacterModel(
        id: '2',
        name: 'Max der Erfinder',
        description: 'Ein kreativer Tüftler mit unendlicher Fantasie',
        appearance: 'Kurze blonde Haare, blaue Augen, immer mit Werkzeug',
        personality: 'Kreativ, geduldig und einfallsreich',
        traits: const CharacterTraitsModel(
          courage: 65,
          creativity: 95,
          helpfulness: 85,
          humor: 75,
          wisdom: 70,
          curiosity: 80,
          empathy: 70,
          persistence: 90,
        ),
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        adoptionCount: 8,
        readCount: 28,
        lastInteractionAt: DateTime.now().subtract(const Duration(days: 1)),
        level: 6,
        experienceCount: 25,
      ),
      CharacterModel(
        id: '3',
        name: 'Zara die Magierin',
        description: 'Eine weise Zauberin mit magischen Kräften',
        appearance: 'Violette Haare, goldene Augen, Zauberumhang',
        personality: 'Weise, empathisch und geheimnisvoll',
        traits: const CharacterTraitsModel(
          courage: 75,
          creativity: 85,
          helpfulness: 90,
          humor: 55,
          wisdom: 95,
          curiosity: 75,
          empathy: 95,
          persistence: 85,
        ),
        isPublic: false,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        adoptionCount: 15,
        readCount: 52,
        lastInteractionAt: DateTime.now().subtract(const Duration(minutes: 30)),
        level: 10,
        experienceCount: 48,
      ),
    ];
  }
}
