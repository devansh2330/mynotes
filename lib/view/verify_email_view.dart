import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('verify email'),
      ),
      body: Column(children: [
        const Text(
            "we've sent you an email verification,please open it to verify your account"),
        const Text(
            "if you haven't recieved the email yet, use the button below"),
        TextButton(
          onPressed: () async {
            AuthService.firebase().sendEmailVerification();
          },
          child: const Text('Send Email verification'),
        ),
        TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text(
              'restart',
            ))
      ]),
    );
  }
}
