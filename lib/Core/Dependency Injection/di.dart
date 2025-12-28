// lib/core/dependency_injection/di.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../Data/Repositories/auth_repository_impl.dart';
import '../../Data/Repositories/file_repository_impl.dart';
import '../../Data/Sources/Remote/auth_remote_source.dart';
import '../../Data/Sources/Remote/file_remote_source.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../../Domain/Repositories/file_repository.dart';
import '../../Domain/Usecases/auth/validate_credentials_usecase.dart';
import '../../Domain/Usecases/files/create_dir_usecase.dart';
import '../../Domain/Usecases/files/create_file_usecase.dart';
import '../../Domain/Usecases/files/delete_usecase.dart';
import '../../Domain/Usecases/files/get_file_content_usecase.dart';
import '../../Domain/Usecases/files/get_files_usecase.dart';
import '../../Domain/Usecases/files/save_file_content_usecase.dart';
import '../../Domain/Usecases/files/touch_usecase.dart';
import '../../Presentation/Bloc/auth/auth_bloc.dart';
import '../../Presentation/Bloc/files/files_bloc.dart';
import '../../Presentation/Bloc/theme/theme_bloc.dart';


final sl = GetIt.instance;

Future<void> initDI() async {
  // External: Shared Dio instance
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    // Optional: Add logging in debug mode
    // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  });

  // Remote Data Sources
  sl.registerLazySingleton<AuthRemoteSource>(() => AuthRemoteSource(sl<Dio>()));
  sl.registerLazySingleton<FileRemoteSource>(() => FileRemoteSource(sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(sl<AuthRemoteSource>()));
  sl.registerLazySingleton<FileRepository>(
          () => FileRepositoryImpl(sl<FileRemoteSource>()));

  // Use Cases
  sl.registerLazySingleton<ValidateCredentialsUseCase>(
          () => ValidateCredentialsUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<GetFilesUseCase>(
          () => GetFilesUseCase(sl<FileRepository>()));
  sl.registerLazySingleton<CreateDirUseCase>(
          () => CreateDirUseCase(sl<FileRepository>()));
  sl.registerLazySingleton<CreateFileUseCase>(
          () => CreateFileUseCase(sl<FileRepository>()));
  sl.registerLazySingleton<TouchUseCase>(
          () => TouchUseCase(sl<FileRepository>()));
  sl.registerLazySingleton<DeleteUseCase>(
          () => DeleteUseCase(sl<FileRepository>()));
  sl.registerLazySingleton<GetFileContentUseCase>(
          () => GetFileContentUseCase(sl<FileRepository>()));
  sl.registerLazySingleton<SaveFileContentUseCase>(
          () => SaveFileContentUseCase(sl<FileRepository>()));

  // Blocs (factory because they have local state)
  sl.registerFactory<ThemeBloc>(() => ThemeBloc());
  sl.registerFactory<AuthBloc>(
          () => AuthBloc(sl<ValidateCredentialsUseCase>()));
  sl.registerFactory<FilesBloc>(() => FilesBloc(
    sl<GetFilesUseCase>(),
    sl<CreateDirUseCase>(),
    sl<CreateFileUseCase>(),
    sl<TouchUseCase>(),
    sl<DeleteUseCase>(),
    sl<GetFileContentUseCase>(),
    sl<SaveFileContentUseCase>(),
  ));
}