import 'package:flutter/material.dart';
import 'package:my_chatting_app/components/my_button.dart';
import 'package:my_chatting_app/components/my_textfield.dart';

import '../Services/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  //email and pw text controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  //tap to go to login
  final void Function()? onTap;

  RegisterPage({
    super.key,
    required this.onTap,
  });

  //login method
  void register(BuildContext context) {
    //get auth service
    final _auth = AuthServices();

    //password match -> create user
    if(_pwController.text == _confirmPwController.text) {
      try{
        final userCredential = _auth.signUpWithEmailAndPassword(_emailController.text, _pwController.text);
      }
      //catch error
      catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            )
        );
      }
    }
    //password do not match -> show error
    else {
      showDialog(
        context: context,
        builder: (context) =>
           const AlertDialog(
              title: Text("Passwords do not match"),
           ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 50,),

              //welcome back msg
              Text(
                "Lets create an account for you!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25,),

              //email textfield
              MyTextfield(
                hintText: 'Email',
                obscureText: false,
                controller: _emailController,
                focusNode: FocusNode(),
              ),
              const SizedBox(height: 10,),

              //pw textfield
              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: _pwController,
                focusNode: FocusNode(),
              ),
              const SizedBox(height: 10,),

              // confirm pw textfield
              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: _confirmPwController,
                focusNode: FocusNode(),
              ),

              const SizedBox(height: 25,),

              //login button
              MyButton(
                text: 'Register',
                onTap: () => register(context),
              ),

              const SizedBox(height: 25,),

              //register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Login now',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}
