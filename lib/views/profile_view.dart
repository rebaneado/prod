import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../managers/fire_auth.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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

    // CustomScrollView(
    //   slivers: <Widget>[
    //     CupertinoSliverNavigationBar(
    //       largeTitle: Text('profile'),
    //     ),
    //   ],
    // );
  }
}
