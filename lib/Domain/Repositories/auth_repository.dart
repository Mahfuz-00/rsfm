abstract class AuthRepository {
  Future<bool> validate(String url, String password);
}