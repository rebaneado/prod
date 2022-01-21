import 'package:flutter/material.dart';

class Song {
  String songName;
  String artist;
  String webURL;
  String songID;
  String album;

  String get getSongName {
    return this.songName;
  }

  String get getArtist {
    return this.artist;
  }

  String get getWebURL {
    return this.webURL;
  }

  String get getSongID {
    return this.songID;
  }

  String get getAlbum {
    return this.album;
  }

  void set setSongID(String spotifySongID) {
    this.songID = spotifySongID;
  }

  Song(this.songName, this.album, this.artist, this.songID, this.webURL);
}
