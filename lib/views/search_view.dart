import 'dart:developer';

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
          this.songName = value;
          this.songString = songName;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomePageView(), //TODO::::------------------------------------------
                ),
              );
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
    try {
      await SpotifySdk.queue(
          //String soptify
          spotifyUri: tempSong);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
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
    // var podcast = await spotify.shows.get('4AlxqGkkrqe0mfIx3Mi7Xt');
    // print(podcast.name);

    // print('\nPodcast episode:');
    // var episodes = await spotify.shows.episodes('4AlxqGkkrqe0mfIx3Mi7Xt');
    // var firstEpisode = (await episodes.first()).items!.first;
    // print(firstEpisode.name);

    // print('Artists:');
    // var artists = await spotify.artists.list(['0OdUWJ0sBjDrqHygGUXeCF']);
    // artists.forEach((x) => print(x.name));

    // print('\nAlbum:');
    // var album = await spotify.albums.get('2Hog1V8mdTWKhCYqI5paph');
    // print(album.name);

    // print('\nAlbum Tracks:');
    // var tracks = await spotify.albums.getTracks(album.id!).all();
    // tracks.forEach((track) {
    //   print(track.name);
    // });

    // print('\nFeatured Playlist:');
    // var featuredPlaylists = await spotify.playlists.featured.all();
    // featuredPlaylists.forEach((playlist) {
    //   print(playlist.name);
    // });

    print("\nSearching for \'Mecleartallica\':");
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
        // if (item is PlaylistSimple) {
        //   print('Playlist: \n'
        //       'id: ${item.id}\n'
        //       'name: ${item.name}:\n'
        //       'collaborative: ${item.collaborative}\n'
        //       'href: ${item.href}\n'
        //       'trackslink: ${item.tracksLink!.href}\n'
        //       'owner: ${item.owner}\n'
        //       'public: ${item.owner}\n'
        //       'snapshotId: ${item.snapshotId}\n'
        //       'type: ${item.type}\n'
        //       'uri: ${item.uri}\n'
        //       'images: ${item.images!.length}\n'
        //       '-------------------------------');
        // }
        // if (item is Artist) {
        //   print('Artist: \n'
        //       'id: ${item.id}\n'
        //       'name: ${item.name}\n'
        //       'href: ${item.href}\n'
        //       'type: ${item.type}\n'
        //       'uri: ${item.uri}\n'
        //       '-------------------------------');
        // }
        if (item is TrackSimple) {
          searchedSongURI = '${item.uri}';
          tempSong = searchedSongURI;
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
        // if (item is AlbumSimple) {
        //   print('Album:\n'
        //       'id: ${item.id}\n'
        //       'name: ${item.name}\n'
        //       'href: ${item.href}\n'
        //       'type: ${item.type}\n'
        //       'uri: ${item.uri}\n'
        //       'albumType: ${item.albumType}\n'
        //       'artists: ${item.artists!.length}\n'
        //       'availableMarkets: ${item.availableMarkets!.length}\n'
        //       'images: ${item.images!.length}\n'
        //       'releaseDate: ${item.releaseDate}\n'
        //       'releaseDatePrecision: ${item.releaseDatePrecision}\n'
        //       '-------------------------------');
        // }
      });
    });

    // var relatedArtists =
    //     await spotify.artists.relatedArtists('0OdUWJ0sBjDrqHygGUXeCF');
    // print('\nRelated Artists: ${relatedArtists.length}');

    credentials = await spotify.getCredentials();
    print('\nCredentials:');
    print('Client Id: ${credentials.clientId}');
    print('Access Token: ${credentials.accessToken}');
    print('Credentials Expired: ${credentials.isExpired}');
  }

  void sendData(var sendDataVariable) {
    String varName = sendDataVariable.name;
    String artist = sendDataVariable.artists!.length;
    String webURL = sendDataVariable.uri;
    String songID = sendDataVariable.id;
    String href = sendDataVariable.href;
    String imageURI = sendDataVariable.type;

    SpotifySdk.getPlayerState();

    Song tempSong = Song(varName, artist, webURL, songID, href, imageURI);
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}
