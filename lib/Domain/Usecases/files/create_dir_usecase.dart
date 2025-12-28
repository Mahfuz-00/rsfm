import '../../Repositories/file_repository.dart';

class CreateDirUseCase {
  final FileRepository repository;

  CreateDirUseCase(this.repository);

  Future<void> execute(String url, String password, String path, String dirname) {
    return repository.createDir(url, password, path, dirname);
  }
}