import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Presentation/Bloc/auth/auth_bloc.dart';
import '../../Presentation/Bloc/files/files_bloc.dart';
import '../../Presentation/Screens/files_screen.dart';
import '../../Presentation/Screens/login_screen.dart';
import '../Dependency Injection/di.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/files',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<FilesBloc>(),
        child: const FilesScreen(),
      ),
    ),
  ],
);