import 'package:flutter/material.dart';
import 'package:prod/main.dart';
import 'package:prod/managers/fire_auth.dart';
import 'package:prod/views/login_view.dart';
import 'package:prod/views/home_view.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  String username = "";

  String password = "";

  String email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [_signUpForm(context), _showLoginButton(context)],
      ),
    ));
  }

  Widget _signUpForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _usernameField(),
            _emailField(),
            _passwordField(),
            _signUpButton(context)
          ],
        ),
      ),
    );
  }

  Widget _usernameField() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        hintText: 'Username',
      ),
      validator: (value) {
        if (value == null) {
          return "Username Can not be emmpty";
        }
        return null;
      },
      onChanged: (value) {
        username = value;
      },
    );
  }

  Widget _emailField() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        hintText: 'email',
      ),
      validator: (value) {
        if (value == null) {
          return "email Can not be emmpty";
        }
        return null;
      },
      onChanged: (value) {
        email = value;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        hintText: 'password',
      ),
      validator: (value) {
        if (value == null) {
          return "password Can not be emmpty";
        }
        return null;
      },
      onChanged: (value) {
        password = value;
      },
    );
  }

  Widget _signUpButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthCheck(),
              ),
            );
          }
          //print('this is username: $email');
          print('this is the password: $password');
          context.read<AuthService>().signUp(email: email, password: password);
        },
        child: const Text('Sign Up bro :) '));
  }

  Widget _showLoginButton(BuildContext context) {
    return SafeArea(
        child: TextButton(
            child: Text('Already have an account? Login!'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginView(),
                ),
              );
            }));
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
