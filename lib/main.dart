import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prod/managers/auth_manager.dart';
import 'package:prod/managers/fire_auth.dart';
import 'package:prod/views/SecondAPP/second_home.dart';
import 'package:prod/views/home_view.dart';
import 'package:prod/views/login_view.dart';
import 'package:prod/views/profile_view.dart';
import 'package:prod/views/search_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
            create: (_) =>
                AuthService(FirebaseAuth.instance)), //This is provider first
        StreamProvider(
            create: (context) => context.read<AuthService>().authStateChange,
            initialData: null)
      ],
      child: CupertinoApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        // ! updated this to comment out homepage and i am putting in login page instead
        //! commented out login view 2nd round to create a class so that it indicates if user is logged in

        // home: MyHomePage(),
        //home: LoginView(),
        home: AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null && firebaseUser.email == "admin@rebaneado.com") {
      //return Text("Signed in ");
      //! the user admin to be able to view the whole app is conditioned above - its admin@rebaneado.com
      return MyHomePage();
    } else if (firebaseUser != null) {
      //this is for the every day user
      //return SecondMain();//! this is correct - if the user is not admin then the user should be redirected to the 'second app....'
      //!however: a easier alrenative would be to hide admin only funcitnoality
      return MyHomePage();
    } else
      return LoginView();
    //return Text("Not Signed in");
  }
}

// Main Screen
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> _tabs = [
    //! 4/11/22 - I replaced below HomePageView(),

    AuthManager(),
    const Profile(), // see the HomeTab class below
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
