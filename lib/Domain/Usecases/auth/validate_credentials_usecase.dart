import '../../Repositories/auth_repository.dart';

class ValidateCredentialsUseCase {
  final AuthRepository repository;

  ValidateCredentialsUseCase(this.repository);

  Future<bool> call(String url, String password) {
    return repository.validate(url, password);
  }
}