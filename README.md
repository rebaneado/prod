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
User is promped to log in below or create account - once authenticated with google firebase, the process in the next video will initiate which is Authentification between spotify services and local app.  
![Login Screen ](https://user-images.githubusercontent.com/36418354/181995379-80dc7581-49f0-4d71-a602-56b0fffd18c7.JPEG)




https://user-images.githubusercontent.com/36418354/181995407-d7a81669-5c4a-4fdd-8d3a-b09a7746c064.mp4



# Spotify-Connect
