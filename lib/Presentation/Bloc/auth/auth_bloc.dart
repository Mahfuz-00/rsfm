import 'package:bloc/bloc.dart';
import '../../../Common/Helper/connection_checker.dart';
import '../../../Domain/Usecases/auth/validate_credentials_usecase.dart';
part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ValidateCredentialsUseCase validateUseCase;

  AuthBloc(this.validateUseCase) : super(AuthInitial()) {
    on<AuthPing>(_onPing);
    on<AuthProceed>((_, emit) => emit(AuthSuccess()));
  }

  Future<void> _onPing(AuthPing event, Emitter<AuthState> emit) async {
    if (!await ConnectionChecker.isConnected()) {
      emit(AuthFailure('No internet connection'));
      return;
    }

    emit(AuthLoading());

    try {
      final success = await validateUseCase(event.url, event.password);
      if (success) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('Invalid credentials or server error'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}