// lib/features/characters/domain/repositories/characters_repository.dart
import '../../../../core/utils/typedef.dart';
import '../entities/character.dart';

abstract class CharactersRepository {
  // Charakter-CRUD-Operationen
  ResultFuture<List<Character>> getCharacters();
  ResultFuture<List<Character>> getPublicCharacters();
  ResultFuture<Character> getCharacterById(String id);
  ResultFuture<Character> createCharacter(Character character);
  ResultFuture<Character> updateCharacter(Character character);
  ResultVoid deleteCharacter(String id);
  
  // Suchfunktionen
  ResultFuture<List<Character>> searchCharacters(String query);
  ResultFuture<List<Character>> getCharactersByFamily(String familyId);
  
  // Soziale Funktionen
  ResultVoid adoptCharacter(String characterId);
  ResultVoid makeCharacterPublic(String characterId);
  ResultVoid makeCharacterPrivate(String characterId);
  
  // Interaktionen
  ResultVoid recordInteraction(String characterId);
  ResultVoid updateCharacterTraits(String characterId, Map<String, int> traitChanges);
}
