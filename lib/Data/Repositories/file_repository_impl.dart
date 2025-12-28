// lib/data/repositories/file_repository_impl.dart
import '../../Domain/Entities/file_entity.dart';
import '../../Domain/Repositories/file_repository.dart';
import '../../Data/Sources/Remote/file_remote_source.dart';


class FileRepositoryImpl implements FileRepository {
  final FileRemoteSource remoteSource;
  FileRepositoryImpl(this.remoteSource);

  @override
  Future<List<FileEntity>> getFiles(String url, String password, String path) async {
    final models = await remoteSource.getFiles(url, password, path);
    print('Loaded File Models : $models');
    return models.map((m) => FileEntity.fromModel(m)).toList();
  }

  @override
  Future<void> createDir(String url, String password, String path, String dirname) =>
      remoteSource.createDir(url, password, path, dirname);

  @override
  Future<void> createFile(String url, String password, String path, String fname) =>
      remoteSource.createFile(url, password, path, fname);

  @override
  Future<void> touch(String url, String password, String path, String fname) =>
      remoteSource.touch(url, password, path, fname);

  @override
  Future<void> delete(String url, String password, String path) =>
      remoteSource.delete(url, password, path);

  @override
  Future<String> getFileContent(String url, String password, String path) =>
      remoteSource.getFileContent(url, password, path);

  @override
  Future<void> saveFileContent(String url, String password, String path, String content) =>
      remoteSource.saveFileContent(url, password, path, content);
}