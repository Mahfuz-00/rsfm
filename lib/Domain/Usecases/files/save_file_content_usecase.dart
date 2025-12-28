import '../../Repositories/file_repository.dart';

class SaveFileContentUseCase {
  final FileRepository repository;

  SaveFileContentUseCase(this.repository);

  Future<void> execute(String url, String password, String path, String content) {
    return repository.saveFileContent(url, password, path, content);
  }
}