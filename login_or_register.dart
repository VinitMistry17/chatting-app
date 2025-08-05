import 'package:flutter/material.dart';

import '../../Screens/login_screen.dart';
import '../../Screens/register_screen.dart';


class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initially show login screen
  bool showLoginPage = true;

  //toggle between login and register screens
  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: toggleScreens,
      );
    } else {
      return RegisterPage(
        onTap: toggleScreens,
      );
    }
  }
}
