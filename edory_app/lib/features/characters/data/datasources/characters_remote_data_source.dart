// lib/features/characters/data/datasources/characters_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/character_model.dart';

// part 'characters_remote_data_source.g.dart'; // TODO: Generate with build_runner

// TODO: Uncomment when build_runner generates the implementation
// @RestApi(baseUrl: ApiConstants.baseUrl)
abstract class CharactersRemoteDataSource {
  // factory CharactersRemoteDataSource(Dio dio) = _CharactersRemoteDataSource;
  
  // Temporary factory for mock
  factory CharactersRemoteDataSource(Dio dio) {
    throw UnimplementedError('Use mock repository for now');
  }

  @GET(ApiConstants.charactersEndpoint)
  Future<List<CharacterModel>> getCharacters();

  @GET(ApiConstants.publicCharactersEndpoint)
  Future<List<CharacterModel>> getPublicCharacters();

  @GET('${ApiConstants.charactersEndpoint}/{id}')
  Future<CharacterModel> getCharacterById(@Path('id') String id);

  @POST(ApiConstants.charactersEndpoint)
  Future<CharacterModel> createCharacter(@Body() CharacterModel character);

  @PUT('${ApiConstants.charactersEndpoint}/{id}')
  Future<CharacterModel> updateCharacter(
    @Path('id') String id,
    @Body() CharacterModel character,
  );

  @DELETE('${ApiConstants.charactersEndpoint}/{id}')
  Future<void> deleteCharacter(@Path('id') String id);

  @GET('${ApiConstants.charactersEndpoint}/search')
  Future<List<CharacterModel>> searchCharacters(@Query('q') String query);

  @GET('${ApiConstants.charactersEndpoint}/family/{familyId}')
  Future<List<CharacterModel>> getCharactersByFamily(@Path('familyId') String familyId);

  @POST('${ApiConstants.charactersEndpoint}/{id}/adopt')
  Future<void> adoptCharacter(@Path('id') String characterId);

  @PUT('${ApiConstants.charactersEndpoint}/{id}/public')
  Future<void> makeCharacterPublic(@Path('id') String characterId);

  @PUT('${ApiConstants.charactersEndpoint}/{id}/private')
  Future<void> makeCharacterPrivate(@Path('id') String characterId);

  @POST('${ApiConstants.charactersEndpoint}/{id}/interaction')
  Future<void> recordInteraction(@Path('id') String characterId);

  @PUT('${ApiConstants.charactersEndpoint}/{id}/traits')
  Future<void> updateCharacterTraits(
    @Path('id') String characterId,
    @Body() Map<String, int> traitChanges,
  );
}
