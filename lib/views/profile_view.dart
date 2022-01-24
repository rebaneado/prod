import 'package:flutter/cupertino.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
        child: CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text('profile'),
        )
      ],
    ));

    // CustomScrollView(
    //   slivers: <Widget>[
    //     CupertinoSliverNavigationBar(
    //       largeTitle: Text('profile'),
    //     ),
    //   ],
    // );
  }
}
