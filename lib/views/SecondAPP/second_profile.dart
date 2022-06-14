import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prod/managers/fire_auth.dart';
import 'package:provider/provider.dart';

class SecondProfileTab extends StatefulWidget {
  SecondProfileTab({Key? key}) : super(key: key);

  @override
  State<SecondProfileTab> createState() => _SecondProfileTabState();
}

class _SecondProfileTabState extends State<SecondProfileTab> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('profile'),
      ),
      child: Center(
        child: ElevatedButton(
            onPressed: () {
              context.read<AuthService>().signOut();
            },
            child: Text('logoutttttt')),
      ),
    );
  }
}
