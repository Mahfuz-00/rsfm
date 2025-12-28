import '../../Repositories/file_repository.dart';

class TouchUseCase {
  final FileRepository repository;

  TouchUseCase(this.repository);

  Future<void> execute(String url, String password, String path, String fname) {
    return repository.touch(url, password, path, fname);
  }
}