// lib/features/characters/domain/usecases/get_characters.dart
import '../../../../core/utils/typedef.dart';
import '../entities/character.dart';
import '../repositories/characters_repository.dart';

class GetCharacters {
  const GetCharacters(this._repository);

  final CharactersRepository _repository;

  ResultFuture<List<Character>> call() => _repository.getCharacters();
}
