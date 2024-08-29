part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthSuccess extends AuthState {
  final String uid;

  const AuthSuccess({required this.uid});

  @override
  List<Object?> get props => [uid];
}

final class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}
