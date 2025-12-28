import '../../Data/Models/file_model.dart';

class FileEntity {
  final String type;
  final String path;
  final String name;
  final int? size;
  final String? humanReadableSize;
  final int mtime;
  final int ctime;
  final String mod;

  FileEntity({
    required this.type,
    required this.path,
    required this.name,
    this.size,
    this.humanReadableSize,
    required this.mtime,
    required this.ctime,
    required this.mod,
  });

  factory FileEntity.fromModel(FileModel model) {
    return FileEntity(
      type: model.type,
      path: model.path,
      name: model.name,
      size: model.size,
      humanReadableSize: model.humanReadableSize,
      mtime: model.mtime,
      ctime: model.ctime,
      mod: model.mod,
    );
  }
}