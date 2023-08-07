import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FireSearch extends StatefulWidget {
  FireSearch({Key? key}) : super(key: key);

  @override
  State<FireSearch> createState() => _FireSearchState();
}

class _FireSearchState extends State<FireSearch> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: TextField(controller: controller),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                final name = controller.text;
                createSong(name: name);
              },
            ),
          ],
        ),
      );

  Future createSong({required String name}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc('my-id');

    final json = {
      'name': name,
      'artist': 'idk',
      'birthday': DateTime(2019, 7, 28),
    };
  }
}

// class _MyHomePageState extends State<MyHomePage> {
//   List<Widget> _tabs = [
//     //! 4/11/22 - I replaced below HomePageView(),

//     AuthManager(),
//     Profile(), // see the HomeTab class below
//     SearchView() // see the SettingsTab class below
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       resizeToAvoidBottomInset: false,
// //TODO: i comented this out and the ugly bar is gone so thats good
//       //navigationBar: CupertinoNavigationBar(),
// /////////////// figure out how to remove that cupertino nav bar
//       ///Next todo is to remove this major eue sore that is messing up my whole layout..

//       child: CupertinoTabScaffold(
//           resizeToAvoidBottomInset: false,
//           tabBar: CupertinoTabBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.person), label: 'Person'),
//               BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search')
//             ],
//           ),
//           tabBuilder: (BuildContext context, index) {
//             return _tabs[index];
//           }),
//     );
//   }
// }
