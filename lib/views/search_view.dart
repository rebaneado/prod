import 'package:flutter/material.dart';
import 'package:prod/views/login_view.dart';
import 'package:prod/views/home_view.dart';

class SearchView extends StatelessWidget {
  //final _formKey = GlobalKey<FormState>();
  const SearchView({Key? key}) : super(key: key);

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

  String songName = "";
  String artist = "";
  String webURL = "";
  String songID = "";
  String album = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [_searchForm(context), _goBackToSomething(context)],
      ),
    ));
  }

  Widget _searchForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    return TextFormField(
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
      },
    );
  }

  Widget _webURL() {
    return TextFormField(
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
    );
  }

  Widget _artistNameField() {
    return TextFormField(
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
    );
  }

  Widget _songID() {
    return TextFormField(
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
    );
  }

  Widget _searchButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          //songList.add()
          print(songName);

          if (_formKey.currentState!.validate()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageView(), //TODO::::
              ),
            );
          }
        },
        child: const Text('Search'));
  }

  Widget _goBackToSomething(BuildContext context) {
    return SafeArea(
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
}
