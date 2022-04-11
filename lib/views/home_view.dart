import 'dart:collection';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prod/model/song_model.dart';
import 'package:prod/widgets/title_widget.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/platform_channels.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:prod/managers/auth_manager.dart';
import 'package:logger/logger.dart';

class HomePageView extends StatefulWidget {
  HomePageView({Key? key}) : super(key: key);
  Queue<Song> songList = Queue<Song>();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomePageView> {
  Queue<Song> songList = Queue<Song>();
  bool _connected = false;
  bool _loading = false;
  bool result = false;
  late ImageUri? currentTrackImageUri;
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

  void connect() async {
    setState(() {
      _loading = true;
    });
    var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: "ca721ff887074f0699d961c2c1f32bd9",
        redirectUrl: "spotify-login-sdk-test-app://spotify-login-callback");
    _connected = true;

    print('this is the result $result');
    log('data: $result');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter layout Demo',
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              titleSection,
              currentSongTitle(),
              //AuthManager(),
//! auth manager is disabled here

              ///TODO: this should be a button to be pressed instead of running automaticallhy so it authenticates when i want it to
              //implenebnt TODO: create a whole button for authg manager

              clickButton(), // i did the template
              songInformation(),
              buildPlayerStateWidget()

              //spotifyImageWidget(SpotifySdk.getImage(imageUri: Player)),

              // Playlist(),
              // AddRemoveSongButtons(),
              // AudioProgressBar(),
              // AudioControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget currentSongTitle() {
    if (songList.isEmpty) {
      print('This is supposed to be a column');

      return const Text('Nothing Currently Playing, no item of songList');
    } else {
      String currentSongName = songList.first.getSongName;
      print('This is if its not empty');
      return Text('Song Playing: $currentSongName');
    }
  }

  Widget clickButton() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            //songList.add()
            //print('So this is the updated song name thing aparently $songName');
            //getSearchedSongInfo();
            //AuthManager();
            connect;

            print(' so this is auth manager running>????? ');
            // if (_formKey.currentState!.validate()) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) =>
            //           HomePageView(), //TODO::::------------------------------------------
            //     ),
            //   );
            // }
          },
          child: const Text('Connect to auth manager')),
    );

    //  ElevatedButton(
    //               onPressed: () {
    //                 AuthManager();
    //               },
    //               child: Text('con'))
  }

//this widget is specifically for getting the image of the song

  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.large,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
            //setStatus(snapshot.error.toString());
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

  Widget buildPlayerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;
        var playerState = snapshot.data;
        log('data: This is buildplayerstatewidget track snapshot... i ownder why this does work and the other does not: ${track?.name}'); //THIS WORKS AND I CAN GRAB RIGHT HERE!!!!!!!!!!!!

        // if (playerState == null || track == null) {
        //   return Center(
        //     child: Container(),
        //   );
        // }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: <Widget>[
            //     SizedIconButton(
            //       width: 50,
            //       icon: Icons.skip_previous,
            //       onPressed: skipPrevious,
            //     ),
            //     playerState.isPaused
            //         ? SizedIconButton(
            //             width: 50,
            //             icon: Icons.play_arrow,
            //             onPressed: resume,
            //           )
            //         : SizedIconButton(
            //             width: 50,
            //             icon: Icons.pause,
            //             onPressed: pause,
            //           ),
            //     SizedIconButton(
            //       width: 50,
            //       icon: Icons.skip_next,
            //       onPressed: skipNext,
            //     ),
            //   ],
            // ),
            Text(
                '${track?.name} by ${track?.artist.name} from the album ${track?.album.name}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Playback speed: ${playerState?.playbackSpeed}'),
                Text(
                    'Progress: ${playerState?.playbackPosition}ms/${track?.duration}ms'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paused: ${playerState?.isPaused}'),
                Text('Shuffling: ${playerState?.playbackOptions.isShuffling}'),
              ],
            ),
            Text('RepeatMode: ${playerState?.playbackOptions.repeatMode}'),
            Text('Image URI: ${track?.imageUri.raw}'),
            Text('Is episode? ${track?.isEpisode}'),
            Text('Is podcast? ${track?.isPodcast}'),
            _connected
                ? spotifyImageWidget(track!.imageUri)
                : const Text('Connect to see an image...'),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Divider(),
            //     const Text(
            //       'Set Shuffle and Repeat',
            //       style: TextStyle(fontSize: 16),
            //     ),
            //     Row(
            //       children: [
            //         const Text(
            //           'Repeat Mode:',
            //         ),
            //         DropdownButton<RepeatMode>(
            //           value: RepeatMode
            //               .values[playerState.playbackOptions.repeatMode.index],
            //           items: const [
            //             DropdownMenuItem(
            //               value: RepeatMode.off,
            //               child: Text('off'),
            //             ),
            //             DropdownMenuItem(
            //               value: RepeatMode.track,
            //               child: Text('track'),
            //             ),
            //             DropdownMenuItem(
            //               value: RepeatMode.context,
            //               child: Text('context'),
            //             ),
            //           ],
            //           onChanged: (repeatMode) => setRepeatMode(repeatMode!),
            //         ),
            //       ],
            //     ),
            //     Row(
            //       children: [
            //         const Text('Set shuffle: '),
            //         Switch.adaptive(
            //           value: playerState.playbackOptions.isShuffling,
            //           onChanged: (bool shuffle) => setShuffle(
            //             shuffle,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        );
      },
    );
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

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    logger.i('$code$text');
  }

  Widget songInformation() {
    MethodNames.getPlayerState;

    return Column(

        //  print('Track:\n'
        //         'id: ${item.id}\n'
        //         'name: ${item.name}\n'
        //         'href: ${item.href}\n'
        //         'type: ${item.type}\n'
        //         'uri: ${item.uri}\n'
        //         'isPlayable: ${item.isPlayable}\n'
        //         'artists: ${item.artists!.length}\n'
        //         'availableMarkets: ${item.availableMarkets!.length}\n'
        //         'discNumber: ${item.discNumber}\n'
        //         'trackNumber: ${item.trackNumber}\n'
        //         'explicit: ${item.explicit}\n'
        //         '-------------------------------');

        ///TODO HERE
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        // children: <Widget>[
        //   Text('Title: ${playerContext.title}'),
        //   Text('Subtitle: ${playerContext.subtitle}'),
        //   Text('Type: ${playerContext.type}'),
        //   Text('Uri: ${playerContext.uri}'),
        // ],
        );
  }
}

// class DisplaySong(){

//   String d = 'd';
// }

// class Playlist extends StatelessWidget {
//   const Playlist({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return Expanded(
//       child: ValueListenableBuilder<List<String>>(
//         valueListenable: pageManager.playlistNotifier,
//         builder: (context, playlistTitles, _) {
//           return ListView.builder(
//             itemCount: playlistTitles.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text('${playlistTitles[index]}'),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class AddRemoveSongButtons extends StatelessWidget {
//   const AddRemoveSongButtons({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           FloatingActionButton(
//             onPressed: pageManager.add,
//             child: Icon(Icons.add),
//           ),
//           FloatingActionButton(
//             onPressed: pageManager.remove,
//             child: Icon(Icons.remove),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AudioProgressBar extends StatelessWidget {
//   const AudioProgressBar({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<ProgressBarState>(
//       valueListenable: pageManager.progressNotifier,
//       builder: (_, value, __) {
//         return ProgressBar(
//           progress: value.current,
//           buffered: value.buffered,
//           total: value.total,
//           onSeek: pageManager.seek,
//         );
//       },
//     );
//   }
// }

// class AudioControlButtons extends StatelessWidget {
//   const AudioControlButtons({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           RepeatButton(),
//           PreviousSongButton(),
//           PlayButton(),
//           NextSongButton(),
//           ShuffleButton(),
//         ],
//       ),
//     );
//   }
// }

// class RepeatButton extends StatelessWidget {
//   const RepeatButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<RepeatState>(
//       valueListenable: pageManager.repeatButtonNotifier,
//       builder: (context, value, child) {
//         Icon icon;
//         switch (value) {
//           case RepeatState.off:
//             icon = Icon(Icons.repeat, color: Colors.grey);
//             break;
//           case RepeatState.repeatSong:
//             icon = Icon(Icons.repeat_one);
//             break;
//           case RepeatState.repeatPlaylist:
//             icon = Icon(Icons.repeat);
//             break;
//         }
//         return IconButton(
//           icon: icon,
//           onPressed: pageManager.repeat,
//         );
//       },
//     );
//   }
// }

// class PreviousSongButton extends StatelessWidget {
//   const PreviousSongButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<bool>(
//       valueListenable: pageManager.isFirstSongNotifier,
//       builder: (_, isFirst, __) {
//         return IconButton(
//           icon: Icon(Icons.skip_previous),
//           onPressed: (isFirst) ? null : pageManager.previous,
//         );
//       },
//     );
//   }
// }

// class PlayButton extends StatelessWidget {
//   const PlayButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<ButtonState>(
//       valueListenable: pageManager.playButtonNotifier,
//       builder: (_, value, __) {
//         switch (value) {
//           case ButtonState.loading:
//             return Container(
//               margin: EdgeInsets.all(8.0),
//               width: 32.0,
//               height: 32.0,
//               child: CircularProgressIndicator(),
//             );
//           case ButtonState.paused:
//             return IconButton(
//               icon: Icon(Icons.play_arrow),
//               iconSize: 32.0,
//               onPressed: pageManager.play,
//             );
//           case ButtonState.playing:
//             return IconButton(
//               icon: Icon(Icons.pause),
//               iconSize: 32.0,
//               onPressed: pageManager.pause,
//             );
//         }
//       },
//     );
//   }
// }

// class NextSongButton extends StatelessWidget {
//   const NextSongButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<bool>(
//       valueListenable: pageManager.isLastSongNotifier,
//       builder: (_, isLast, __) {
//         return IconButton(
//           icon: Icon(Icons.skip_next),
//           onPressed: (isLast) ? null : pageManager.next,
//         );
//       },
//     );
//   }
// }

// class ShuffleButton extends StatelessWidget {
//   const ShuffleButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<bool>(
//       valueListenable: pageManager.isShuffleModeEnabledNotifier,
//       builder: (context, isEnabled, child) {
//         return IconButton(
//           icon: (isEnabled)
//               ? Icon(Icons.shuffle)
//               : Icon(Icons.shuffle, color: Colors.grey),
//           onPressed: pageManager.shuffle,
//         );
//       },
//     );
//   }
// }
