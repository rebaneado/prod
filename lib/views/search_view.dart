import 'package:flutter/material.dart';
import 'package:prod/views/login_view.dart';
import 'package:prod/views/home_view.dart';

class SearchView extends StatelessWidget {
  //final _formKey = GlobalKey<FormState>();
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

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
          songName = value;
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

            if (_formKey.currentState!.validate()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageView(), //TODO::::
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
}
