import '../../Domain/Repositories/auth_repository.dart';
import '../Sources/Remote/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource source;

  AuthRepositoryImpl(this.source);

  @override
  Future<bool> validate(String url, String password) {
    return source.ping(url, password);
  }
}