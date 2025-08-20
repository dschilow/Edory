// lib/core/providers/repository_providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/characters/data/datasources/characters_remote_data_source.dart';
import '../../features/characters/data/repositories/characters_mock_repository_impl.dart';
import '../../features/characters/data/datasources/characters_remote_data_source_impl.dart';
import '../../features/characters/data/repositories/characters_repository_impl.dart';
import '../../features/characters/domain/repositories/characters_repository.dart';
import '../constants/api_constants.dart';

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: ApiConstants.defaultHeaders,
  );
  
  // Add interceptors for logging, error handling, etc.
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  
  return dio;
});

// Data Sources
final charactersRemoteDataSourceProvider = Provider<CharactersRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CharactersRemoteDataSourceImpl(dio);
});

// Repositories
final charactersRepositoryProvider = Provider<CharactersRepository>((ref) {
  // Echt: Backend anbinden
  final remoteDataSource = ref.watch(charactersRemoteDataSourceProvider);
  return CharactersRepositoryImpl(remoteDataSource);
});
