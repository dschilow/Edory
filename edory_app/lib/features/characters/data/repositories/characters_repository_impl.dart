// lib/features/characters/data/repositories/characters_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/characters_repository.dart';
import '../datasources/characters_remote_data_source.dart';
import '../models/character_model.dart';

class CharactersRepositoryImpl implements CharactersRepository {
  const CharactersRepositoryImpl(this._remoteDataSource);

  final CharactersRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<Character>> getCharacters() async {
    try {
      final result = await _remoteDataSource.getCharacters();
      return Right(result.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Character>> getPublicCharacters() async {
    try {
      final result = await _remoteDataSource.getPublicCharacters();
      return Right(result.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Character> getCharacterById(String id) async {
    try {
      final result = await _remoteDataSource.getCharacterById(id);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Character> createCharacter(Character character) async {
    try {
      final model = CharacterModel.fromEntity(character);
      final result = await _remoteDataSource.createCharacter(model);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Character> updateCharacter(Character character) async {
    try {
      final model = CharacterModel.fromEntity(character);
      final result = await _remoteDataSource.updateCharacter(character.id, model);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteCharacter(String id) async {
    try {
      await _remoteDataSource.deleteCharacter(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Character>> searchCharacters(String query) async {
    try {
      final result = await _remoteDataSource.searchCharacters(query);
      return Right(result.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Character>> getCharactersByFamily(String familyId) async {
    try {
      final result = await _remoteDataSource.getCharactersByFamily(familyId);
      return Right(result.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid adoptCharacter(String characterId) async {
    try {
      await _remoteDataSource.adoptCharacter(characterId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid makeCharacterPublic(String characterId) async {
    try {
      await _remoteDataSource.makeCharacterPublic(characterId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid makeCharacterPrivate(String characterId) async {
    try {
      await _remoteDataSource.makeCharacterPrivate(characterId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid recordInteraction(String characterId) async {
    try {
      await _remoteDataSource.recordInteraction(characterId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid updateCharacterTraits(String characterId, Map<String, int> traitChanges) async {
    try {
      await _remoteDataSource.updateCharacterTraits(characterId, traitChanges);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
