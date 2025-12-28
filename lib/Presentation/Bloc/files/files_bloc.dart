import 'package:bloc/bloc.dart';
import '../../../Common/Helper/connection_checker.dart';
import '../../../Domain/Entities/file_entity.dart';
import '../../../Domain/Usecases/files/create_dir_usecase.dart';
import '../../../Domain/Usecases/files/create_file_usecase.dart';
import '../../../Domain/Usecases/files/delete_usecase.dart';
import '../../../Domain/Usecases/files/get_file_content_usecase.dart';
import '../../../Domain/Usecases/files/get_files_usecase.dart';
import '../../../Domain/Usecases/files/save_file_content_usecase.dart';
import '../../../Domain/Usecases/files/touch_usecase.dart';
part 'files_event.dart';
part 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final GetFilesUseCase getFilesUseCase;
  final CreateDirUseCase createDirUseCase;
  final CreateFileUseCase createFileUseCase;
  final TouchUseCase touchUseCase;
  final DeleteUseCase deleteUseCase;
  final GetFileContentUseCase getFileContentUseCase;
  final SaveFileContentUseCase saveFileContentUseCase;

  String url = '';
  String password = '';
  String currentPath = '~';

  FilesBloc(
      this.getFilesUseCase,
      this.createDirUseCase,
      this.createFileUseCase,
      this.touchUseCase,
      this.deleteUseCase,
      this.getFileContentUseCase,
      this.saveFileContentUseCase,
      ) : super(FilesInitial()) {
    on<InitFiles>((event, emit) {
      url = event.url;
      password = event.password;
      add(LoadFiles());
    });

    on<LoadFiles>((event, emit) async {
      if (!await ConnectionChecker.isConnected()) {
        emit(FilesError('No internet connection'));
        return;
      }
      emit(FilesLoading());
      try {
        final files = await getFilesUseCase.execute(url, password, currentPath);
        print('Loaded Files: $files');
        emit(FilesLoaded(files));
      } catch (e) {
        print('Loaded File Error: $e');
        emit(FilesError(e.toString()));
      }
    });

    on<NavigateToPath>((event, emit) {
      currentPath = event.path;
      add(LoadFiles());
    });

    on<CreateDirectory>((event, emit) async {
      try {
        await createDirUseCase.execute(url, password, currentPath, event.dirname);
        add(LoadFiles());
      } catch (e) {
        emit(FilesError(e.toString()));
      }
    });

    on<CreateFile>((event, emit) async {
      try {
        await createFileUseCase.execute(url, password, currentPath, event.fname);
        add(LoadFiles());
      } catch (e) {
        emit(FilesError(e.toString()));
      }
    });

    on<TouchItem>((event, emit) async {
      try {
        await touchUseCase.execute(url, password, currentPath, event.fname);
        add(LoadFiles());
      } catch (e) {
        emit(FilesError(e.toString()));
      }
    });

    on<DeleteItem>((event, emit) async {
      try {
        await deleteUseCase.execute(url, password, event.path);
        add(LoadFiles());
      } catch (e) {
        emit(FilesError(e.toString()));
      }
    });

    on<LoadFileContent>((event, emit) async {
      try {
        final content = await getFileContentUseCase.execute(url, password, event.path);
        emit(FileContentLoaded(content));
      } catch (e) {
        emit(FilesError(e.toString()));
      }
    });

    on<SaveFileContent>((event, emit) async {
      try {
        await saveFileContentUseCase.execute(url, password, event.path, event.content);
        emit(FileContentSaved());
      } catch (e) {
        emit(FilesError(e.toString()));
      }
    });
  }
}