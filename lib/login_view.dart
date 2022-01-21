import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prod/views/sign_up_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hello this is the title',
      home: LoginScaffold(),
    );
  }
}

class LoginScaffold extends StatefulWidget {
  const LoginScaffold({Key? key}) : super(key: key);

  @override
  LoginScaffoldState createState() => LoginScaffoldState();
}

class LoginScaffoldState extends State<LoginScaffold> {
  final _formKey = GlobalKey<FormState>();
  String username = "";
  String password = "";
  String emaill = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          loginForm(),
          signUpButton(),
        ],
      )),
    );
  }

  Widget loginForm() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_userNameField(), _passwordField(), _loginButton()]),
        ));
  } // end of loginForm Widget

  Widget signUpButton() {
    return SafeArea(
        child: TextButton(
            child: Text('Don\'t have an account? Sign Up.'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignUpView(),
                ),
              );
            }));
  }

  Widget _userNameField() {
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

  Widget _passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        hintText: 'Password',
      ),
      validator: (value) {
        if (value == null) {
          return "Password Can not be emmpty";
        }
        return null;
      },
      onChanged: (value) {
        password = value;
      },
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Data')),
            );

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SignUpView(),
            //   ),
            // );
          }
        },
        child: const Text('Login'));
  }
} // this is end of loginScaffoldState class
