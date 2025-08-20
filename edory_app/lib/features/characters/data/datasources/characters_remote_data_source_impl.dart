// lib/features/characters/data/datasources/characters_remote_data_source_impl.dart
import 'package:dio/dio.dart';
import 'characters_remote_data_source.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/character_model.dart';

class CharactersRemoteDataSourceImpl implements CharactersRemoteDataSource {
  CharactersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // Demo: Fallback FamilyId bis echte User-Familie vorhanden ist
  static const String _demoFamilyId = '11111111-1111-1111-1111-111111111111';

  @override
  Future<List<CharacterModel>> getCharacters() async {
    final resp = await _dio.get(ApiConstants.charactersEndpoint);
    final List data = resp.data as List;
    return data.map((e) => CharacterModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<List<CharacterModel>> getPublicCharacters() async {
    final resp = await _dio.get(ApiConstants.publicCharactersEndpoint);
    final List data = resp.data as List;
    return data.map((e) => CharacterModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<CharacterModel> getCharacterById(String id) async {
    final resp = await _dio.get('${ApiConstants.charactersEndpoint}/$id');
    return CharacterModel.fromJson(Map<String, dynamic>.from(resp.data));
  }

  @override
  Future<CharacterModel> createCharacter(CharacterModel character) async {
    // Backend erwartet CreateCharacterRequest mit flachen Trait-Feldern und familyId
    final body = {
      'name': character.name,
      'description': character.description,
      'appearance': character.appearance,
      'personality': character.personality,
      'familyId': _demoFamilyId, // TODO: echte FamilyId injecten
      'minAge': 3,
      'maxAge': 12,
      'courage': character.traits.courage,
      'creativity': character.traits.creativity,
      'helpfulness': character.traits.helpfulness,
      'humor': character.traits.humor,
      'wisdom': character.traits.wisdom,
      'curiosity': character.traits.curiosity,
      'empathy': character.traits.empathy,
      'persistence': character.traits.persistence,
    };

    final resp = await _dio.post(ApiConstants.charactersEndpoint, data: body);
    return CharacterModel.fromJson(Map<String, dynamic>.from(resp.data));
  }

  @override
  Future<CharacterModel> updateCharacter(String id, CharacterModel character) async {
    final resp = await _dio.put('${ApiConstants.charactersEndpoint}/$id', data: character.toJson());
    return CharacterModel.fromJson(Map<String, dynamic>.from(resp.data));
  }

  @override
  Future<void> deleteCharacter(String id) async {
    await _dio.delete('${ApiConstants.charactersEndpoint}/$id');
  }

  @override
  Future<List<CharacterModel>> searchCharacters(String query) async {
    final resp = await _dio.get('${ApiConstants.charactersEndpoint}/search', queryParameters: {'q': query});
    final List data = resp.data as List;
    return data.map((e) => CharacterModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<List<CharacterModel>> getCharactersByFamily(String familyId) async {
    final resp = await _dio.get('${ApiConstants.charactersEndpoint}/family/$familyId');
    final List data = resp.data as List;
    return data.map((e) => CharacterModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> adoptCharacter(String characterId) async {
    await _dio.post('${ApiConstants.charactersEndpoint}/$characterId/adopt');
  }

  @override
  Future<void> makeCharacterPublic(String characterId) async {
    await _dio.put('${ApiConstants.charactersEndpoint}/$characterId/public');
  }

  @override
  Future<void> makeCharacterPrivate(String characterId) async {
    await _dio.put('${ApiConstants.charactersEndpoint}/$characterId/private');
  }

  @override
  Future<void> recordInteraction(String characterId) async {
    await _dio.post('${ApiConstants.charactersEndpoint}/$characterId/interaction');
  }

  @override
  Future<void> updateCharacterTraits(String characterId, Map<String, int> traitChanges) async {
    await _dio.put('${ApiConstants.charactersEndpoint}/$characterId/traits', data: traitChanges);
  }
}


