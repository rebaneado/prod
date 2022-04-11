import 'dart:developer';

import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/models/connection_status.dart';
//import 'package:spotify/spotify.dart'; //this one too this one was the latest maybe idk
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';

//import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthManager extends StatefulWidget {
  AuthManager({Key? key}) : super(key: key);

  @override
  State<AuthManager> createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  bool _loading = false;

  bool _connected = false;
  late String searchedSongURI, tempSong;

  late String songString, artistsString;

  Logger logger = Logger(
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
    //? made update here to create a scafforld object
    return MaterialApp(
      home: StreamBuilder<ConnectionStatus>(
          stream: SpotifySdk.subscribeConnectionStatus(),
          builder: (context, snapshot) {
            _connected = false;
            var data = snapshot.data;
            if (data != null) {
              _connected = data.connected;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('SpotifySdk Example'),
                actions: [
                  _connected
                      ? IconButton(
                          onPressed: disconnect,
                          icon: const Icon(Icons.exit_to_app),
                        )
                      : Container()
                ],
              ),
              body: _architectureFlow(context),
            );
          }),
    );

    //!connectRemote();
    //ConnectRemote();
    return buildPlayerContextWidget();
  } // this is build widget close brack

  Widget _architectureFlow(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(9),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                    onPressed: connectRemote,
                    child: const Icon(Icons.settings_accessibility)),
                const Divider(),
                const Text(
                  'Player Context',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _connected
                    ? buildPlayerContextWidget()
                    : const Center(
                        child: Text('Not connected'),
                      ),
              ],
            )
          ],
        )
      ],
    );
  }

  Future<String> connectRemote() async {
    try {
      var authentificationToken = await SpotifySdk.connectToSpotifyRemote(
          clientId: 'ca721ff887074f0699d961c2c1f32bd9'.toString(),
          redirectUrl:
              'spotify-login-sdk-test-app://spotify-login-callback'.toString(),
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authentificationToken');
      return authentificationToken.toString();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }

    // print('THIS IS NOT AWAITING SHIT');

    // String clientId = "ca721ff887074f0699d961c2c1f32bd9";
    // String redirectUrl = "spotify-login-sdk-test-app://spotify-login-callback";
    // String = SpotifySdk.getAuthenticationToken(
    //     clientId: clientId, redirectUrl: redirectUrl).spotifyUri;
    // print(authentificationToken);
    // await SpotifySdk.pause();
    //await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');

    ///TODO: use this in my playing method wheveever i am going to maintaing this
  }

  void nameFunc(String searchedSong) {
    SpotifySdk.queue(spotifyUri: searchedSong);
    var asdfwer = SpotifySdk.getPlayerState();
    log('data: ----------------------------------------------------------- THis is player state variable $asdfwer');
  }

  Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Widget buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
        var playerContext = snapshot.data;
        log('data: This log file is inside buildplayercontextwidget and below is the playercontext?titlesubtitle, type, and uri  $snapshot');

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                '============================================================================================================================='),
            Text('Title: ${playerContext?.title}'),
            Text('Subtitle: ${playerContext?.subtitle}'),
            Text('Type: ${playerContext?.type}'),
            Text('Uri: ${playerContext?.uri}'),
          ],
        );
      },
    );
  }

  Future<void> checkIfAppIsActive(BuildContext context) async {
    try {
      var isActive = await SpotifySdk.isSpotifyAppActive;
      final snackBar = SnackBar(
          content: Text(isActive
              ? 'Spotify app connection is active (currently playing)'
              : 'Spotify app connection is not active (currently not playing)'));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      // setState(() {
      //   _loading = true;
      // });
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: dotenv.env['ca721ff887074f0699d961c2c1f32bd9'].toString(),
          redirectUrl: dotenv
              .env['spotify-login-sdk-test-app://spotify-login-callback']
              .toString());

      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      // setState(() {
      //   _loading = false;
      // });
    } on PlatformException catch (e) {
      _loading = false;

      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      _loading = false;

      setStatus('not implemented');
    }
  }

  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.disconnect();
      setStatus(result ? 'disconnect successful' : 'disconnect failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    logger.i('$code$text');
  }
}
