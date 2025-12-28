import '../../Entities/file_entity.dart';
import '../../Repositories/file_repository.dart';

class GetFilesUseCase {
  final FileRepository repository;

  GetFilesUseCase(this.repository);

  Future<List<FileEntity>> execute(String url, String password, String path) {
    return repository.getFiles(url, password, path);
  }
}