import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ulearning_app/pages/register/bloc/register_blocs.dart';

import '../../common/widgets/flutter_toast.dart';

class RegisterController {
  final BuildContext context;
  const RegisterController({required this.context});

  void handleEmailRegister() async {
    final state = context.read<RegisterBlocs>().state;

    String userName = state.username;
    String email = state.email;
    String password = state.password;
    String rePassword = state.rePassword;

    if (userName.isEmpty) {
      toastInfo(msg: 'Username can not be empty');
      return;
    }
    if (email.isEmpty) {
      toastInfo(msg: 'Email can not be empty');
      return;
    }

    if (password.isEmpty) {
      toastInfo(msg: 'Password can not be empty');
      return;
    }
    if (rePassword.isEmpty) {
      toastInfo(msg: 'Your password confirmation is empty');
      return;
    }
    if (password != rePassword) {
      toastInfo(msg: 'Your password and password confirmation does not match');
      return;
    }

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user?.sendEmailVerification();
        await credential.user?.updateDisplayName(userName);
        toastInfo(msg: 'Check your email to verify your account');
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        toastInfo(msg: 'The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        toastInfo(msg: 'The account already exists for that email');
      } else if (e.code == 'invalid-email') {
        toastInfo(msg: 'The email is not valid');
      } else if (e.code == 'operation-not-allowed') {
        toastInfo(msg: 'Operation not allowed');
      }
    }
  }
}
