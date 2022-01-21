//I dont think i need this class object for queue becuase queue class already exists from
//Dart: collection

import 'package:flutter/cupertino.dart';
import 'dart:collection';

import 'package:prod/model/song_model.dart';

class SongQueue {
  Queue<Song> songList = Queue<Song>();
}
