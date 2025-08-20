// lib/features/characters/domain/usecases/create_character.dart
import '../../../../core/utils/typedef.dart';
import '../entities/character.dart';
import '../repositories/characters_repository.dart';

class CreateCharacter {
  const CreateCharacter(this._repository);

  final CharactersRepository _repository;

  ResultFuture<Character> call(Character character) => 
      _repository.createCharacter(character);
}
