import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class AuthManager extends StatelessWidget {
  const AuthManager({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ConnectRemote();
    return Container();
  }

  Future<void> ConnectRemote() async {
    await SpotifySdk.getAuthenticationToken(
        clientId: "ca721ff887074f0699d961c2c1f32bd9",
        redirectUrl: "spotify-login-sdk-test-app://spotify-login-callback",
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing');
    print('THIS IS NOT AWAITING SHIT');

    String clientId = "ca721ff887074f0699d961c2c1f32bd9";
    String redirectUrl = "spotify-login-sdk-test-app://spotify-login-callback";
    // String = SpotifySdk.getAuthenticationToken(
    //     clientId: clientId, redirectUrl: redirectUrl).spotifyUri;
    // print(authToken);
    await SpotifySdk.pause();
    await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
  }
}
