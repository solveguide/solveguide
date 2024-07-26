import 'package:firebase_auth/firebase_auth.dart';
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
          bool isValidEmail(String email) {
            final emailRegExp = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
            return emailRegExp.hasMatch(email);
          }

          if (!isValidEmail(email)) {
            emit(
              AuthFailure('Please enter a valid email.'),
            );
            return;
          }

          //password length check
          if (password.length < 6) {
            emit(
              AuthFailure('Password cannot be less than 6 characters.'),
            );
            return;
          }
          // navigate on success
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          final user = FirebaseAuth.instance.currentUser!;
          return emit(AuthSuccess(uid: user.uid));
        } catch (e) {
          return emit(
            AuthFailure(
              e.toString(),
            ),
          );
        }
      },
    );
    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.signOut();
          return emit(AuthInitial());

      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
