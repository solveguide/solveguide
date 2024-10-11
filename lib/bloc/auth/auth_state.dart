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

  const AuthSuccess({required this.uid});
  final String uid;

  @override
  List<Object?> get props => [uid];
}

final class AuthFailure extends AuthState {

  const AuthFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}
