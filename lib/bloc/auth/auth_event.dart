part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

final class AppStarted extends AuthEvent {
  const AppStarted();
}

final class AnnonymousUserBlocked extends AuthEvent {
  const AnnonymousUserBlocked();
}
