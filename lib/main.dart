import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prod/views/home_view.dart';
import 'package:prod/views/login_view.dart';
import 'package:prod/views/profile_view.dart';
import 'package:prod/views/search_view.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      // ! updated this to comment out homepage and i am putting in login page instead
      //! commented out login view 2nd round to create a class so that it indicates if user is logged in

      // home: MyHomePage(),
      //home: LoginView(),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Main Screen
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> _tabs = [
    HomePageView(),
    Profile(), // see the HomeTab class below
    SearchView() // see the SettingsTab class below
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
//TODO: i comented this out and the ugly bar is gone so thats good
      //navigationBar: CupertinoNavigationBar(),
/////////////// figure out how to remove that cupertino nav bar
      ///Next todo is to remove this major eue sore that is messing up my whole layout..

      child: CupertinoTabScaffold(
          resizeToAvoidBottomInset: false,
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Person'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search')
            ],
          ),
          tabBuilder: (BuildContext context, index) {
            return _tabs[index];
          }),
    );
  }
}

// Home Tab
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Tab'),
    );
  }
}

// Settings Tab
class SettingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings Tab'),
    );
  }
}

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Tab'),
    );
  }
}
