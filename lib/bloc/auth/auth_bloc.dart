import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      emit(AuthSuccess(uid: currentUser.uid));
    } catch (error) {
      emit(AuthInitial());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    if (!_authRepository.isValidEmail(event.email)) {
      emit(
        AuthFailure('Please enter a valid email.'),
      );
      return;
    }
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
          event.email, event.password);
      emit(AuthSuccess(uid: user!.uid));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(AuthInitial());
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    if (!_authRepository.isValidEmail(event.email)) {
      emit(
        AuthFailure('Please enter a valid email.'),
      );
      return;
    }
    if (event.password.length < 6) {
      emit(
        AuthFailure('Password cannot be less than 6 characters.'),
      );
      return;
    }
    try {
      final user = await _authRepository.registerWithEmailAndPassword(
          event.email, event.password);
      emit(AuthSuccess(uid: user!.uid));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }
}
