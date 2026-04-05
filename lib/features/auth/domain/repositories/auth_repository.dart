// lib/features/auth/domain/repositories/auth_repository.dart
import '../../../../core/utils/result.dart'; // Adjust path
import '../models/login_request.dart';
import '../models/register_request.dart';

abstract class AuthRepository {
  Future<Result<void>> login(LoginRequest request);
  Future<Result<void>> register(RegisterRequest request);
  Future<Result<void>> refreshToken();
  Future<bool> hasRefreshToken();
  Future<Result<void>> logout();
}
