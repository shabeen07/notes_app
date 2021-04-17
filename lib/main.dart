import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/pages/notes_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey 
      ),
      home: NotesList(),
    );
  }
}
