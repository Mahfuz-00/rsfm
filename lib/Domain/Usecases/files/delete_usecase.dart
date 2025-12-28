import '../../Repositories/file_repository.dart';

class DeleteUseCase {
  final FileRepository repository;

  DeleteUseCase(this.repository);

  Future<void> execute(String url, String password, String path) {
    return repository.delete(url, password, path);
  }
}