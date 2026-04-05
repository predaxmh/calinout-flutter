import 'package:calinout/core/logger/talker.dart';
import 'package:calinout/core/networking/dio_client.dart';
import 'package:calinout/features/auth/data/datasources/auth_api_service.dart';
import 'package:calinout/features/auth/data/datasources/token_storage.dart';
import 'package:calinout/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:calinout/features/auth/domain/repositories/auth_repository.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
TokenStorage tokenStorage(Ref ref) {
  final talker = ref.watch(talkerProvider);

  return TokenStorage(talker);
}

@riverpod
AuthApiService authApiService(Ref ref) {
  final dio = ref.watch(dioProvider);

  return AuthApiService(dio);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final apiService = ref.watch(authApiServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final talker = ref.watch(talkerProvider);

  return AuthRepositoryImpl(apiService, tokenStorage, talker);
}
