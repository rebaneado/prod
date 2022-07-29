# Spotify-Connect

This application was created with the Gym/Bar/Restaurant/Social-event and gathering scenario to allow all individuals present the ability tosubmit songs to the queue of the currentlly playing music from their own decices  without having access to the main device playing music. 


A IOS/Android/Web Music based project designed with a full backend database allowing users to create/login/personalize their profiles. The intent of this effort is to allow users login and connect to the main admin Device(The Device that is playing music over the speakers at a public enviorment) and have the ability to sent/receive data to it.

**Technology used: **
- Google Firebase Authentication for user creation/log on/storage as the backend
- Google Firebase Realtime Database for fetching and storing current and next up song information from main device to be pulled from user devices
- Spotify Developer for client keys and creation of redirect URLs
- Flutter with DART languge
- Spotify Authentification allowing the main device to connect to the spotify servers and verify the valid account to play a track
- Spotify libraries allowing searching of songs and queing next songs.  

**MAIN  DEVICE PLAYING MUSIC **
- Full control of the music 
- Send and receive requests straight from Spotify servers after AuthO2 has been completed.
- 
**USER ABILITIES**

- See current track title playing, artwork, album,etc...
- Ability to go to the next tab to search for a song and send a queue request as string to the database in which the main admin user constantly reads the string data, pulls and submits request to spotify to queue next song


## Screenshots Demo

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
![image](https://user-images.githubusercontent.com/36418354/181787480-52f81d65-d382-4797-9305-830df50aa5d5.png)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# Spotify-Connect
