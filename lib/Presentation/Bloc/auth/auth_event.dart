// auth_event.dart
part of 'auth_bloc.dart';

sealed class AuthEvent {}

class AuthPing extends AuthEvent {
  final String url;
  final String password;
  AuthPing(this.url, this.password);
}

class AuthProceed extends AuthEvent {}
