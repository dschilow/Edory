// lib/features/characters/presentation/providers/characters_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/character.dart';
import '../../domain/usecases/get_characters.dart';
import '../../domain/usecases/get_public_characters.dart';
import '../../domain/usecases/create_character.dart';
import '../../../../core/providers/repository_providers.dart';

// Characters State
final charactersProvider = StateNotifierProvider<CharactersNotifier, AsyncValue<List<Character>>>((ref) {
  final getCharacters = GetCharacters(ref.watch(charactersRepositoryProvider));
  return CharactersNotifier(getCharacters);
});

// Public Characters State
final publicCharactersProvider = StateNotifierProvider<PublicCharactersNotifier, AsyncValue<List<Character>>>((ref) {
  final getPublicCharacters = GetPublicCharacters(ref.watch(charactersRepositoryProvider));
  return PublicCharactersNotifier(getPublicCharacters);
});

// Selected Character State
final selectedCharacterProvider = StateProvider<Character?>((ref) => null);

// Character Creation State
final characterCreationProvider = StateNotifierProvider<CharacterCreationNotifier, AsyncValue<Character?>>((ref) {
  final createCharacter = CreateCharacter(ref.watch(charactersRepositoryProvider));
  return CharacterCreationNotifier(createCharacter);
});

class CharactersNotifier extends StateNotifier<AsyncValue<List<Character>>> {
  CharactersNotifier(this._getCharacters) : super(const AsyncValue.loading());

  final GetCharacters _getCharacters;

  Future<void> loadCharacters() async {
    state = const AsyncValue.loading();
    final result = await _getCharacters();
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (characters) => state = AsyncValue.data(characters),
    );
  }

  void addCharacter(Character character) {
    state.whenData((characters) {
      state = AsyncValue.data([...characters, character]);
    });
  }

  void updateCharacter(Character updatedCharacter) {
    state.whenData((characters) {
      final updatedList = characters.map((character) {
        return character.id == updatedCharacter.id ? updatedCharacter : character;
      }).toList();
      state = AsyncValue.data(updatedList);
    });
  }

  void removeCharacter(String characterId) {
    state.whenData((characters) {
      final updatedList = characters.where((character) => character.id != characterId).toList();
      state = AsyncValue.data(updatedList);
    });
  }
}

class PublicCharactersNotifier extends StateNotifier<AsyncValue<List<Character>>> {
  PublicCharactersNotifier(this._getPublicCharacters) : super(const AsyncValue.loading());

  final GetPublicCharacters _getPublicCharacters;

  Future<void> loadPublicCharacters() async {
    state = const AsyncValue.loading();
    final result = await _getPublicCharacters();
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (characters) => state = AsyncValue.data(characters),
    );
  }
}

class CharacterCreationNotifier extends StateNotifier<AsyncValue<Character?>> {
  CharacterCreationNotifier(this._createCharacter) : super(const AsyncValue.data(null));

  final CreateCharacter _createCharacter;

  Future<void> createCharacter(Character character) async {
    state = const AsyncValue.loading();
    final result = await _createCharacter(character);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (newCharacter) => state = AsyncValue.data(newCharacter),
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
