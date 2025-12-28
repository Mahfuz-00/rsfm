import '../../Repositories/file_repository.dart';

class CreateFileUseCase {
  final FileRepository repository;

  CreateFileUseCase(this.repository);

  Future<void> execute(String url, String password, String path, String fname) {
    return repository.createFile(url, password, path, fname);
  }
}