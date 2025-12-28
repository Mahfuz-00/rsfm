part of 'files_bloc.dart';

abstract class FilesEvent {}

class InitFiles extends FilesEvent {
  final String url;
  final String password;

  InitFiles(this.url, this.password);
}

class LoadFiles extends FilesEvent {}

class NavigateToPath extends FilesEvent {
  final String path;

  NavigateToPath(this.path);
}

class CreateDirectory extends FilesEvent {
  final String dirname;

  CreateDirectory(this.dirname);
}

class CreateFile extends FilesEvent {
  final String fname;

  CreateFile(this.fname);
}

class TouchItem extends FilesEvent {
  final String fname;

  TouchItem(this.fname);
}

class DeleteItem extends FilesEvent {
  final String path;

  DeleteItem(this.path);
}

class LoadFileContent extends FilesEvent {
  final String path;

  LoadFileContent(this.path);
}

class SaveFileContent extends FilesEvent {
  final String path;
  final String content;

  SaveFileContent(this.path, this.content);
}