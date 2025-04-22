import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/models/appUser.dart';
import 'package:guide_solve/repositories/appUser_repository.dart';
import 'package:guide_solve/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AnnonymousUserBlocked>(_onAnnonymousUserBlocked);
    on<NewContactAdded>(_onNewContactAdded);
    on<AuthMagicLinkRequested>(_onMagicLinkRequested);
    on<AuthMagicLinkVerifiedWithEmail>(_onMagicLinkVerifiedWithEmail);
  }
  final AuthRepository _authRepository;
  final AppUserRepository _appUserRepository = AppUserRepository();
  String? _currentUserId;
  AppUser? _currentAppUser;

  String? get currentUserId => _currentUserId;
  AppUser? get currentAppUser => _currentAppUser;
  AuthRepository get authRepository => _authRepository;

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      _currentUserId = currentUser.uid;
      _currentAppUser =
          await _appUserRepository.getAppUserById(currentUser.uid);
      emit(AuthSuccess(uid: currentUser.uid));
    } catch (error) {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    if (!_authRepository.isValidEmail(event.email)) {
      emit(
        const AuthFailure('Please enter a valid email.'),
      );
      return;
    }
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      emit(AuthSuccess(uid: user!.uid));
      _currentUserId = user.uid;
      _currentAppUser = await _appUserRepository.getAppUserById(user.uid);
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onMagicLinkRequested(
    AuthMagicLinkRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendMagicLink(event.email);
      emit(const AuthWaitingOnMagicLinkClick()); // Emit a waiting state
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onMagicLinkVerifiedWithEmail(
    AuthMagicLinkVerifiedWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.verifyMagicLinkWithEmail(
          event.magicLink, event.email);
      emit(AuthSuccess(uid: user.uid));
    } catch (error) {
      if (error.toString().contains('email required')) {
        emit(const AuthMagicLinkNeedsEmail());
      } else {
        emit(AuthFailure(error.toString()));
      }
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthInitial());
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    if (!_authRepository.isValidEmail(event.email)) {
      emit(
        const AuthFailure('Please enter a valid email.'),
      );
      return;
    }
    if (event.password.length < 6) {
      emit(
        const AuthFailure('Password cannot be less than 6 characters.'),
      );
      return;
    }
    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        event.email,
        event.password,
      );
      emit(AuthSuccess(uid: user!.uid));
      _currentUserId = user.uid;
      _currentAppUser = await _appUserRepository.getAppUserById(user.uid);
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onAnnonymousUserBlocked(
    AnnonymousUserBlocked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      emit(AuthSuccess(uid: currentUser.uid));
    } catch (error) {
      emit(const AuthInitial());
    }
  }

  FutureOr<void> _onNewContactAdded(
    NewContactAdded event,
    Emitter<AuthState> emit,
  ) {
    //Check for valid email
    //Check if AppUser already exists with email
    //Yes? ->
    //get existing userId,
    //contactName will be (event.contactName ? AppUser.username ? event.email)
    //Add to current user's Contact map <userId, event.contactName>
    //add current user to existing users contact map

    //No? ->
    //Add email to current users invitedContacts list,
    //create a mailto: link that the current user can send,
  }
}
