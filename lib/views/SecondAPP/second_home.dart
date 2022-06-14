import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prod/views/SecondAPP/second_display.dart';
import 'package:prod/views/SecondAPP/second_profile.dart';
import 'package:prod/views/SecondAPP/second_search.dart';

class SecondMain extends StatefulWidget {
  SecondMain({Key? key}) : super(key: key);

  @override
  State<SecondMain> createState() => _SecondMainState();
}

class _SecondMainState extends State<SecondMain> {
  List<Widget> _tabs = [
    //! this is for tabs for secondary home

    SecondCurrentlyPlaying(),
    SecondProfileTab(), // see the HomeTab class below
    SecondSearchTab() // see the SettingsTab class below
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
