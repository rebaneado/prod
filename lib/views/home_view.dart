import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prod/model/song_model.dart';
import 'package:prod/widgets/title_widget.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:prod/managers/auth_manager.dart';

class HomePageView extends StatefulWidget {
  HomePageView({Key? key}) : super(key: key);
  Queue<Song> songList = Queue<Song>();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomePageView> {
  Queue<Song> songList = Queue<Song>();

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
              AuthManager(),

              //spotifyImageWidget(),
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
}


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
