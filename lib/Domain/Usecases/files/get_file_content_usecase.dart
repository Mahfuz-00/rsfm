import '../../Repositories/file_repository.dart';

class GetFileContentUseCase {
  final FileRepository repository;

  GetFileContentUseCase(this.repository);

  Future<String> execute(String url, String password, String path) {
    return repository.getFileContent(url, password, path);
  }
}