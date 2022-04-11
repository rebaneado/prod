import 'dart:developer';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
//import 'package:spotify/spotify.dart'; //this one too this one was the latest maybe idk
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';

//import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../widgets/sized_icon_button.dart';

class AuthManager extends StatefulWidget {
  AuthManager({Key? key}) : super(key: key);

  @override
  State<AuthManager> createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  bool _loading = false;

  bool _connected = false;
  late String searchedSongURI, tempSong;
  late ImageUri? currentTrackImageUri;
  CrossfadeState? crossfadeState;

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
                title: const Text('PlayLoud'),
                actions: [
                  _connected
                      ? IconButton(
                          onPressed: disconnect,
                          icon: const Icon(Icons.exit_to_app),
                        )
                      : Container(),
                  IconButton(
                    onPressed: connectRemote2,
                    icon: const Icon(Icons.connect_without_contact),
                  ),
                  Container(),
                  const Divider(),
                ],
              ),
              body: _architectureFlow(context),
            );
          }),
    );
  } // this is build widget close brack

  Widget _architectureFlow(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(9),
          children: [
            Row(),
            const Divider(),
            const Center(
              child: Text(
                'Player State - Currently playing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _connected
                ? _buildPlayerStateWidget()
                : const Center(
                    child: Text('Not connected'),
                  ),
            const Divider(),
            const Text(
              'Player Context',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            _connected
                ? _buildPlayerContextWidget()
                : const Center(
                    child: Text('Not connected'),
                  ),
          ],
        )
      ],
    );
  }

//!4/11/22 i might have to do away with this one and just use below... but its good to have this for frame of refference.
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

  Future<void> connectRemote2() async {
    try {
      setState(() {
        _loading = true;
      });
      //! this might be the one item that im missing - connect();

      var result = await SpotifySdk.connectToSpotifyRemote(
        clientId:
            'ca721ff887074f0699d961c2c1f32bd9', //dotenv.env['ac47c257f73a48f3835b24f832a63cdc'].toString(),
        redirectUrl: 'spotify-login-sdk-test-app://spotify-login-callback',
        //! 4/11 I deleted this as I think that this needs to go in the GetAuthtoken method... yet to create.
        // scope: 'app-remote-control, '
        //     'user-modify-playback-state, '
        //     'playlist-read-private, '
        //     'playlist-modify-public,user-read-currently-playing'
      );

      var tempbool = true;

      setStatus(tempbool
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
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
//! 4/11 deleted this
  // void nameFunc(String searchedSong) {
  //   SpotifySdk.queue(spotifyUri: searchedSong);
  //   var asdfwer = SpotifySdk.getPlayerState();
  //   log('data: ----------------------------------------------------------- THis is player state variable $asdfwer');
  // }

  Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }
//! 4/11/22 - commented below lines and copined over other buildplayercontext from working project
  // Widget _buildPlayerContextWidget() {
  //   return StreamBuilder<PlayerContext>(
  //     stream: SpotifySdk.subscribePlayerContext(),
  //     initialData: PlayerContext('', '', '', ''),
  //     builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
  //       var playerContext = snapshot.data;
  //       log('data: This log file is inside buildplayercontextwidget and below is the playercontext?titlesubtitle, type, and uri  $snapshot');

  //       return Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Text(
  //               '============================================================================================================================='),
  //           Text('Title: ${playerContext?.title}'),
  //           Text('Subtitle: ${playerContext?.subtitle}'),
  //           Text('Type: ${playerContext?.type}'),
  //           Text('Uri: ${playerContext?.uri}'),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
        var playerContext = snapshot.data;
        log('data: This is what player context.title is as well as subtitle ${playerContext!.title}');

        if (playerContext == null) {
          log('data: THIS MEANS THAT PLAYERCONTEXTIS EMPTY!!!! $playerContext');

          return const Center(
            child: Text('Not connected'),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Title: ${playerContext.title}'),
            Text('Subtitle: ${playerContext.subtitle}'),
            Text('Type: ${playerContext.type}'),
            Text('Uri: ${playerContext.uri}'),
          ],
        );
      },
    );
  }

  Widget _buildPlayerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;
        var playerState = snapshot.data;
        log('This is buildplayerstatewidget track snapshot... i ownder why this does work and the other does not: ${track!.name}'); //THIS WORKS AND I CAN GRAB RIGHT HERE!!!!!!!!!!!!

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _connected
                ? spotifyImageWidget(track.imageUri)
                : const Text('Connect to see an image...'),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedIconButton(
                  width: 50,
                  icon: Icons.skip_previous,
                  onPressed: skipPrevious,
                ),
                playerState.isPaused
                    ? SizedIconButton(
                        width: 50,
                        icon: Icons.play_arrow,
                        onPressed: resume,
                      )
                    : SizedIconButton(
                        width: 50,
                        icon: Icons.pause,
                        onPressed: pause,
                      ),
                SizedIconButton(
                  width: 50,
                  icon: Icons.skip_next,
                  onPressed: skipNext,
                ),
              ],
            ),
            //! 4/11/22 should delete the below commented code because it is already mentioned in the playerCONTEXT widget
            // Text(
            //     '${track.name} by ${track.artist.name} from the album ${track.album.name}'),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text('Playback speed: ${playerState.playbackSpeed}'),
            //     Text(
            //         'Progress: ${playerState.playbackPosition}ms/${track.duration}ms'),
            //   ],
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text('Paused: ${playerState.isPaused}'),
            //     Text('Shuffling: ${playerState.playbackOptions.isShuffling}'),
            //   ],
            // ),
            // Text('RepeatMode: ${playerState.playbackOptions.repeatMode}'),
            // Text('Image URI: ${track.imageUri.raw}'),
            // Text('Is episode? ${track.isEpisode}'),
            // Text('Is podcast? ${track.isPodcast}'),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Set Shuffle and Repeat',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    const Text(
                      'Repeat Mode:',
                    ),
                    DropdownButton<RepeatMode>(
                      value: RepeatMode
                          .values[playerState.playbackOptions.repeatMode.index],
                      items: const [
                        DropdownMenuItem(
                          value: RepeatMode.off,
                          child: Text('off'),
                        ),
                        DropdownMenuItem(
                          value: RepeatMode.track,
                          child: Text('track'),
                        ),
                        DropdownMenuItem(
                          value: RepeatMode.context,
                          child: Text('context'),
                        ),
                      ],
                      onChanged: (repeatMode) => setRepeatMode(repeatMode!),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Set shuffle: '),
                    Switch.adaptive(
                      value: playerState.playbackOptions.isShuffling,
                      onChanged: (bool shuffle) => setShuffle(
                        shuffle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

  Future<String> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId:
              'ca721ff887074f0699d961c2c1f32bd9', //dotenv.env['ac47c257f73a48f3835b24f832a63cdc'].toString(),//commented out the dotenv.env
          redirectUrl:
              'spotify-login-sdk-test-app://spotify-login-callback', //dotenv.env['spotifyConnect://spotify-login-callback'].toString(),
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
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

  Future getCrossfadeState() async {
    try {
      var crossfadeStateValue = await SpotifySdk.getCrossFadeState();
      setState(() {
        crossfadeState = crossfadeStateValue;
      });
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> queue() async {
    try {
      await SpotifySdk.queue(
          spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> queueSong(varuable) async {
    try {
      await SpotifySdk.queue(
          spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> toggleRepeat() async {
    try {
      await SpotifySdk.toggleRepeat();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeatMode,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setShuffle(bool shuffle) async {
    try {
      await SpotifySdk.setShuffle(
        shuffle: shuffle,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> toggleShuffle() async {
    try {
      await SpotifySdk.toggleShuffle();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> seekTo() async {
    try {
      await SpotifySdk.seekTo(positionedMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> seekToRelative() async {
    try {
      await SpotifySdk.seekToRelativePosition(relativeMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> addToLibrary() async {
    try {
      await SpotifySdk.addToLibrary(
          spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Widget spotifyImageWidget(ImageUri image) {
    print(SpotifySdk.getImage(
      imageUri: image,
      dimension: ImageDimension.large,
    ));

    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.large,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
            setStatus(snapshot.error.toString());
            return SizedBox(
              width: ImageDimension.large.value.toDouble(),
              height: ImageDimension.large.value.toDouble(),
              child: const Center(child: Text('Error getting image')),
            );
          } else {
            return SizedBox(
              width: ImageDimension.large.value.toDouble(),
              height: ImageDimension.large.value.toDouble(),
              child: const Center(child: Text('Getting image...')),
            );
          }
        });
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    logger.i('$code$text');
  }
}
