
class FileModel {
  final String type;
  final String path;
  final String name;
  final int? size;
  final String? humanReadableSize;
  final int mtime;
  final int ctime;
  final String mod;

  FileModel({
    required this.type,
    required this.path,
    required this.name,
    this.size,
    this.humanReadableSize,
    required this.mtime,
    required this.ctime,
    required this.mod,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      type: json['type'],
      path: json['path'],
      name: json['name'],
      size: json['size'],
      humanReadableSize: json['human_readable_size'],
      mtime: json['mtime'],
      ctime: json['ctime'],
      mod: json['mod'],
    );
  }
}