//import 'dart:html';
import 'package:spotify/spotify.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/platform_channels.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

//import 'package:spotify_connect/spotif_auth.dart';
import 'package:logger/logger.dart';
import "package:velocity_x/velocity_x.dart";
//import 'package:json_serializable/json_serializable.dart';
import 'dart:io';
import 'dart:convert';
//import 'package:build_runner/build_runner.dart';

//import 'package:spotify_connect/spotif_auth.dart';

class SpotifySearch extends StatefulWidget {
  const SpotifySearch({Key? key}) : super(key: key);

  @override
  _SpotifySearchState createState() => _SpotifySearchState();
}

class _SpotifySearchState extends State<SpotifySearch> {
  //final Logger _logger = Logger();
  final formKey = GlobalKey<FormState>();
  //final form = formKey.currentState;
  late String searchedSongURI, tempSong;

  late String songString, artistsString;
  Color greenColor = Color(0xFF00AF19);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Form Validation Demo';

    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Form(key: formKey, child: searchSongApp())));
  }

  searchSongApp() {
    return Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: ListView(children: [
          SizedBox(height: 75.0),
          Container(
              height: 125.0,
              width: 200.0,
              child: Stack(
                children: [
                  const Text('Hello',
                      style: TextStyle(fontFamily: 'Truneo', fontSize: 60.0)),
                  const Positioned(
                      top: 50.0,
                      child: Text('There',
                          style:
                              TextStyle(fontFamily: 'Truneo', fontSize: 60.0))),
                  Positioned(
                      top: 97.0,
                      left: 175.0,
                      child: Container(
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: greenColor)))
                ],
              )),
          SizedBox(height: 25.0),
          CupertinoFormSection(
            header: "Please login".text.make(),
            children: [
              CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                      placeholder: "Enter song name",
                      onChanged: (value) {
                        songString = value;

                        //insert the value to the method here
                      }),
                  prefix: "Email".text.make()),
              CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                      placeholder: "Enter artists",
                      obscureText: true,
                      onChanged: (value) {
                        artistsString = value;
                      }),
                  prefix: "Passowrd".text.make())
            ],
          ),
          GestureDetector(
              onTap: () {
                //todo
              },
              child: Container(
                  alignment: Alignment(1.0, 0.0),
                  padding: EdgeInsets.only(top: 15.0, left: 20.0),
                  child: InkWell(
                      child: Text('Forgot Password',
                          style: TextStyle(
                              color: greenColor,
                              fontFamily: 'Trueno',
                              fontSize: 11.0,
                              decoration: TextDecoration.underline))))),
          GestureDetector(
            onTap: () {
              getSearchedSongInfo();
              print("Searched song has beemsss has been Ran_______________");

              //if (checkFields()) AuthService().signIn(email, password, context);
            },
            child: Container(
                height: 50.0,
                child: Material(
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Colors.greenAccent,
                  color: greenColor,
                  elevation: 7.0,
                  child: const Center(
                    child: Text('Search Song',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Trueneo')),
                  ),
                )),
          ),
          SizedBox(height: 20.0),
          GestureDetector(
            onTap: () {
              //AuthService().fbSignin(); //TODO
            },
            child: Container(
                height: 50.0,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 1.0),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(
                            //child: ImageIcon(AssetImage('assets/facebook.png'),
                            //size: 5.0),
                            ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Center(
                            child: Text(
                          'Login with Facebook',
                          style: TextStyle(fontFamily: 'Trueno'),
                        ))
                      ],
                    ))),
          ),
          SizedBox(height: 25.0),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('New to Spotify ?'),
            SizedBox(width: 5.0),
            InkWell(
                //MARK3: TODO
                // onTap: () {
                //   Navigator.of(context).push(
                //       MaterialPageRoute(builder: (context) => SignupPage()));
                // },
                child: Text('Register',
                    style: TextStyle(
                        color: greenColor,
                        fontFamily: 'Trueno',
                        decoration: TextDecoration.underline)))
          ])
        ]));
  }

  // void setStatus(String code, {String? message}) {
  //   var text = message ?? '';
  //   _logger.i('$code$text');
  // }

  Future<void> getSearchedSongInfo() async {
    // var keyJson = await File('example/.apikeys').readAsString();
    // var keyMap = json.decode(keyJson);

    // var credentials = SpotifyApiCredentials(
    //     keyMap['ac47c257f73a48f3835b24f832a63cdc'],
    //     keyMap['d97c4f57eb4342cfb6633a062d0d36ae']);
    // var spotify = SpotifyApi(credentials);
    var credentials = SpotifyApiCredentials(
        'ac47c257f73a48f3835b24f832a63cdc', 'd97c4f57eb4342cfb6633a062d0d36ae');
    //tempToken = MethodNames.getAuthenticationToken;
    var spotify = SpotifyApi(credentials);

    print("\nSearching for \'Mecleartallica\':");
    var search = await spotify.search
        .get(songString)
        .first(2)
        .catchError((err) => print((err as SpotifyException).message));
    if (search == null) {
      return;
    }
    search.forEach((pages) {
      pages.items!.forEach((item) {
        if (item is TrackSimple) {
          searchedSongURI = '${item.uri}';
          tempSong = searchedSongURI;
          queueSong(tempSong);
          print('This is idk look at this shit: $searchedSongURI');
          print('This is idk look at this shit222222: $tempSong');
          print(
              'This is ------------------------------------- the searched Song URI: $searchedSongURI');
          print('Track:\n'
              'id: ${item.id}\n'
              'name: ${item.name}\n'
              'href: ${item.href}\n'
              'type: ${item.type}\n'
              'uri: ${item.uri}\n'
              'isPlayable: ${item.isPlayable}\n'
              'artists: ${item.artists!.length}\n'
              'availableMarkets: ${item.availableMarkets!.length}\n'
              'discNumber: ${item.discNumber}\n'
              'trackNumber: ${item.trackNumber}\n'
              'explicit: ${item.explicit}\n'
              '-------------------------------');
        }
      });
    });

    // var relatedArtists =
    //     await spotify.artists.relatedArtists('0OdUWJ0sBjDrqHygGUXeCF');
    // print('\nRelated Artists: ${relatedArtists.length}');
//! commenting this out because i dont thik this is doing anything 3/30/22

    // credentials = await spotify.getCredentials();
    // print('\nCredentials:');
    // print('Client Id: ${credentials.clientId}');
    // print('Access Token: ${credentials.accessToken}');
    // print('Credentials Expired: ${credentials.isExpired}');
  }

  Future<void> queueSong(tempSong) async {
    try {
      await SpotifySdk.queue(
          //String soptify
          spotifyUri: tempSong);
    } on PlatformException catch (e) {
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      // setStatus('not implemented');
    }
  }
}
