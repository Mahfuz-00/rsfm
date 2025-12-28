part of 'files_bloc.dart';

abstract class FilesState {}

class FilesInitial extends FilesState {}

class FilesLoading extends FilesState {}

class FilesLoaded extends FilesState {
  final List<FileEntity> files;

  FilesLoaded(this.files);
}

class FileContentLoaded extends FilesState {
  final String content;

  FileContentLoaded(this.content);
}

class FileContentSaved extends FilesState {}

class FilesError extends FilesState {
  final String message;

  FilesError(this.message);
}