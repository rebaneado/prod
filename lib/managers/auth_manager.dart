import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class AuthManager extends StatelessWidget {
  const AuthManager({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (SpotifySdk.getPlayerState != null) {
    } else {
      ConnectRemote();

      return buildPlayerContextWidget();
    }
  }

  Future<void> ConnectRemote() async {
    await SpotifySdk.getAuthenticationToken(
        clientId: "ca721ff887074f0699d961c2c1f32bd9",
        redirectUrl: "spotify-login-sdk-test-app://spotify-login-callback",
        scope:
            //'app-remote-control, '
            //'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing');
    print('THIS IS NOT AWAITING SHIT');

    String clientId = "ca721ff887074f0699d961c2c1f32bd9";
    String redirectUrl = "spotify-login-sdk-test-app://spotify-login-callback";
    // String = SpotifySdk.getAuthenticationToken(
    //     clientId: clientId, redirectUrl: redirectUrl).spotifyUri;
    // print(authToken);
    // await SpotifySdk.pause();
    //await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');

    ///TODO: use this in my playing method wheveever i am going to maintaing this
  }

  void Name(String searchedSong) {
    SpotifySdk.queue(spotifyUri: searchedSong);
    var asdfwer = SpotifySdk.getPlayerState();
    print(
        '------------------------------------------ THis is player state variable $asdfwer');
  }

  Future getPlayerState() async {
    //var adfasd = PlayerState.track;
    return await SpotifySdk.getPlayerState();
  }

  // Widget _buildPlayerStateWidget() {
  //   StreamBuilder<PlayerState>(
  //     stream: SpotifySdk.subscribePlayerState(),
  //     builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
  //       var track = snapshot.data?.track;
  //       ImageUri? currentTrackImageUri = track?.imageUri;
  //       var playerState = snapshot.data;
  //       print(
  //           'This is buildplayerstatewidget track snapshot... i ownder why this does work and the other does not: ${track!.name}'); //THIS WORKS AND I CAN GRAB RIGHT HERE!!!!!!!!!!!!
  //     },
  //   );

  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Text('Title: ${playerContext.title}'),
  //       Text('Subtitle: ${playerContext.subtitle}'),
  //       Text('Type: ${playerContext.type}'),
  //       Text('Uri: ${playerContext.uri}'),
  //     ],
  //   );
  // }

  Widget buildPlayerContextWidget() {
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

        // return Text(
        //  'data'); //Rebaneado: I have to figure out what goes next here
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
}
