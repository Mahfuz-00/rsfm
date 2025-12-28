import '../Entities/file_entity.dart';

abstract class FileRepository {
  Future<List<FileEntity>> getFiles(String url, String password, String path);
  Future<void> createDir(String url, String password, String path, String dirname);
  Future<void> createFile(String url, String password, String path, String fname);
  Future<void> touch(String url, String password, String path, String fname);
  Future<void> delete(String url, String password, String path);
  Future<String> getFileContent(String url, String password, String path);
  Future<void> saveFileContent(String url, String password, String path, String content);
}