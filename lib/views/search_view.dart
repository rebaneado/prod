import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prod/model/song_model.dart';
import 'package:prod/views/login_view.dart';
import 'package:prod/views/home_view.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';

class SearchView extends StatelessWidget {
  //final _formKey = GlobalKey<FormState>();
  SearchView({Key? key}) : super(key: key);
  // late String searchedSongURI, tempSong;
  // late String songString, artistsString;

  //final double height = MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'afadsfda',
      home: SearchScaffold(),
    );
  }
}

class SearchScaffold extends StatefulWidget {
  const SearchScaffold({Key? key}) : super(key: key);

  @override
  SearchScaffoldState createState() => SearchScaffoldState();
}

class SearchScaffoldState extends State<SearchScaffold> {
  final _formKey = GlobalKey<FormState>();
  late String searchedSongURI, tempSong;
  late String songString, artistsString;
  // var supplyDemmand = null;
  String songName = "";
  String artist = "";
  String webURL = "";
  String songID = "";
  String album = "";
  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [_searchForm(context), _goBackToSomething(context)],
            ),
          ),
        ));
  }

  Widget _searchForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height) * .120,
            ),
            _songNameField(context),
            _artistNameField(),
            _songID(),
            _searchButton(context)
          ],
        ),
      ),
    );
  }

  Widget _songNameField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Song Name',
        ),
        validator: (value) {
          if (value == null) {
            return "Name of Song";
          }
          return null;
        },
        onChanged: (value) {
          songName = value;
          songString = songName;
          //print('THIS IS NOT AWAITING SHIT $songName');
        },
      ),
    );
  }

  Widget _webURL() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'webURL',
        ),
        validator: (value) {
          if (value == null) {
            return "WEB URL";
          }
          return null;
        },
        onChanged: (value) {
          webURL = value;
        },
      ),
    );
  }

  Widget _artistNameField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Artist name',
        ),
        validator: (value) {
          if (value == null) {
            return "Artists Can not be emmpty";
          }
          return null;
        },
        onChanged: (value) {
          artist = value;
        },
      ),
    );
  }

  Widget _songID() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: 'Song ID',
        ),
        validator: (value) {
          if (value == null) {
            return "password Can not be emmpty";
          }
          return null;
        },
        onChanged: (value) {
          songID = value;
        },
      ),
    );
  }

  Widget _searchButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            //songList.add()
            print('So this is the updated song name thing aparently $songName');
            getSearchedSongInfo();

            if (_formKey.currentState!.validate()) {
              showCupertinoDialog<void>(
                context: context,
                builder: (BuildContext context) => CupertinoAlertDialog(
                  title: const Text('Song queued,Thanks.'),
                  content:
                      const Text('Go back to home page to view plaing songs'),
                  actions: <CupertinoDialogAction>[
                    CupertinoDialogAction(
                      child: const Text('ok'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('ok in blue'),
                      isDestructiveAction: true,
                      onPressed: () {
                        // Do something destructive.
                      },
                    )
                  ],
                ),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         HomePageView(), //TODO::::------------------------------------------
              //   ),
              // );
            }
          },
          child: const Text('Search')),
    );
  }

  Widget _goBackToSomething(BuildContext context) {
    return Container(
        alignment: Alignment.bottomCenter,
        child: TextButton(
            child: Text('TODO gp back to something>?'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginView(),
                ),
              );
            }));
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> queueSong(tempSong) async {
    String newTempSong = tempSong.toString();
    try {
      await SpotifySdk.queue(spotifyUri: newTempSong);
      print(
          '----------------------------------------------------------------------------------------------This means that queue went succescully');
    } on PlatformException catch (e) {
      print(
          '----------------------------------------------------------------------------------------------This means that queue went bad -1');
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      print(
          '----------------------------------------------------------------------------------------------This means that queue went bad');
      setStatus(
          '----------------------------------------------------------------------------------------------not implemented');
    }
  }

  final databaseRef =
      FirebaseDatabase.instance.ref(); //database reference object

  void addData(String data) {
    databaseRef.push().set({'name': data, 'comment': 'A good season'});
  }

  Future<void> getSearchedSongInfo() async {
    // var keyJson = await File('example/.apikeys').readAsString();
    // var keyMap = json.decode(keyJson);

    var credentials = SpotifyApiCredentials(
        'ca721ff887074f0699d961c2c1f32bd9', '9715e16eaaa24dd5a7eab2c185b42e95');
    var spotify = SpotifyApi(credentials);

    //____________________________________________________________________________________________________________________this is it where i messed up and commented out the folloiwng

    // var credentials = SpotifyApiCredentials( // this is it
    //     'ac47c257f73a48f3835b24f832a63cdc', 'd97c4f57eb4342cfb6633a062d0d36ae');
    // //tempToken = MethodNames.getAuthenticationToken;
    // var spotify = SpotifyApi(credentials);// this is also it

    // // print('\nPodcast:');

    print('Searching for : $songString');
    var search = await spotify.search
        .get(songString)
        .first(1)
        .catchError((err) => print((err as SpotifyException).message));
    log('this is search item... idk man $search');
    if (search == null) {
      return;
    }
    search.forEach((pages) {
      pages.items!.forEach((item) {
        if (item is TrackSimple) {
          searchedSongURI = '${item.uri}';
          tempSong = searchedSongURI;
          //! this is where i insert into database .
          queueSong(tempSong);

          // supplyDemmand = item;
          // sendData(supplyDemmand);

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

    credentials = await spotify.getCredentials();
    print(
        '----------------------------------------------------------------------------------------------Credentials:');
    print('Client Id: ${credentials.clientId}');
    print('Access Token: ${credentials.accessToken}');
    print('Credentials Expired: ${credentials.isExpired}');
  }
//! deleted the following because fcausing confusion
  // void sendData(var sendDataVariable) {
  //   String varName = sendDataVariable.name;
  //   String artist = sendDataVariable.artists!.length;
  //   String webURL = sendDataVariable.uri;
  //   String songID = sendDataVariable.id;
  //   String href = sendDataVariable.href;
  //   String imageURI = sendDataVariable.type;

  //   SpotifySdk.getPlayerState();

  //   Song tempSong = Song(varName, artist, webURL, songID, href, imageURI);
  // }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}
