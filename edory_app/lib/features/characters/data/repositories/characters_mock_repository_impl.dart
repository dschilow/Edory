// lib/features/characters/data/repositories/characters_mock_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/characters_repository.dart';
import '../datasources/characters_mock_data_source.dart';

class CharactersMockRepositoryImpl implements CharactersRepository {
  @override
  ResultFuture<List<Character>> getCharacters() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockCharacters = CharactersMockDataSource.getMockCharacters();
      return Right(mockCharacters.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Character>> getPublicCharacters() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockCharacters = CharactersMockDataSource.getMockCharacters()
          .where((character) => character.isPublic)
          .toList();
      return Right(mockCharacters.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Character> getCharacterById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final mockCharacter = CharactersMockDataSource.getMockCharacters()
          .firstWhere((character) => character.id == id);
      return Right(mockCharacter.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Character not found'));
    }
  }

  @override
  ResultFuture<Character> createCharacter(Character character) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // In a real implementation, this would call the API
      return Right(character);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Character> updateCharacter(Character character) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return Right(character);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteCharacter(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Character>> searchCharacters(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockCharacters = CharactersMockDataSource.getMockCharacters()
          .where((character) => 
              character.name.toLowerCase().contains(query.toLowerCase()) ||
              character.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return Right(mockCharacters.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Character>> getCharactersByFamily(String familyId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      final mockCharacters = CharactersMockDataSource.getMockCharacters();
      return Right(mockCharacters.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid adoptCharacter(String characterId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid makeCharacterPublic(String characterId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid makeCharacterPrivate(String characterId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid recordInteraction(String characterId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid updateCharacterTraits(String characterId, Map<String, int> traitChanges) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
