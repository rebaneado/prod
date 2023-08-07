// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/animation.dart';

class SecondSearchTab extends StatefulWidget {
  SecondSearchTab({Key? key}) : super(key: key);

  @override
  State<SecondSearchTab> createState() => _SecondSearchTabState();
}

class _SecondSearchTabState extends State<SecondSearchTab>
    with TickerProviderStateMixin {
  late TextEditingController budgetNameController;
  late TextEditingController textController1;
  late TextEditingController textController3;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String secondSongString = "";

  @override
  void initState() {
    super.initState();
    print("initState() called");
    budgetNameController = TextEditingController();
    textController1 = TextEditingController();
    textController3 = TextEditingController();
  }

// I dont think this is needed, it was just attached with example online of init state
  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Color.fromARGB(255, 43, 249, 229),
        body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 44, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: budgetNameController,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                          icon: Icon(Icons.person),
                                          hintText:
                                              'idk bro... im exhausted clearly'),
                                      validator: (value) {
                                        if (value == null) {
                                          return "WEB URL";
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        secondSongString = value;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              )
            ],
          ),
        ));
  }
}
