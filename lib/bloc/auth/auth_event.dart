part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthMagicLinkRequested extends AuthEvent {
  const AuthMagicLinkRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthMagicLinkVerifiedWithEmail extends AuthEvent {
  const AuthMagicLinkVerifiedWithEmail(
      {required this.magicLink, required this.email});

  final String magicLink;
  final String email;

  @override
  List<Object?> get props => [magicLink, email];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AppStarted extends AuthEvent {
  const AppStarted();
}

final class AnnonymousUserBlocked extends AuthEvent {
  const AnnonymousUserBlocked();
}

final class NewContactAdded extends AuthEvent {
  const NewContactAdded({
    required this.contactEmail,
    required this.contactName,
  });
  final String contactEmail;
  final String contactName;

  @override
  List<Object?> get props => [contactEmail, contactName];
}
