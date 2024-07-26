import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(
      (event, emit) async {
        emit(AuthLoading());
        try {
          // get the email
          final email = event.email;
          // get the password
          final password = event.password;
          // check that they are valid
          //email validation using regex?

          //password length check
          if (password.length < 6) {
            emit(
              AuthFailure('Password cannot be less than 6 characters'),
            );
            return;
          }
          // navigate on success

          await Future.delayed(const Duration(seconds: 1), () {
            return emit(
              AuthSuccess(uid: '$email-$password'),
            );
          });
        } catch (e) {
          return emit(
            AuthFailure(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
