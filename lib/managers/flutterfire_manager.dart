import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RealTimeDatabase extends StatefulWidget {
  RealTimeDatabase({Key? key}) : super(key: key);
  FirebaseDatabase database = FirebaseDatabase.instance;
  @override
  State<RealTimeDatabase> createState() => _RealTimeDatabaseState();
}

class _RealTimeDatabaseState extends State<RealTimeDatabase> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
