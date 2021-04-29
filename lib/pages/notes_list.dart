import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'note_details.dart';

class NotesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NoteListState();
  }
}

class _NoteListState extends State<NotesList> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Note> notesList;
  int notesCount = 0;
  SearchBar _searchBar;
  final GlobalKey<ScaffoldState> _globalKey=new GlobalKey<ScaffoldState>();

  AppBar buildAppBar(BuildContext context){
    return new AppBar(
      title: new Text('i-Notes'),
      actions: [_searchBar.getSearchAction(context)],
    );
  }

  void onSubmitted(String searchText){
    setState(() {
      _globalKey.currentState
          .showSnackBar(new SnackBar(content: new Text('you wrote $searchText')));
    });
  }

  _NoteListState(){
    _searchBar=new SearchBar(
      inBar: false,
      buildDefaultAppBar: buildAppBar,
      setState: setState,
      onSubmitted: onSubmitted,
      hintText:'Search notes',
      onCleared: (){
        print('cleared');
      },
      onClosed: (){
        print('closed');
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (notesList == null) {
      notesList = List<Note>();
      _updateListView();
    }

    return Scaffold(
      appBar: _searchBar.build(context),
      body: getNotesList(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a Note',
        child: Icon(Icons.add),
        onPressed: () {
          debugPrint('FAB CLICKED');
          navigateToDetail(Note('', 2, ''), 'Add Note'); // Add a note
        },
      ),
    );
  }

  ListView getNotesList() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
      itemCount: notesCount,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.notesList[index].priority),
              child: getPriorityIcon(this.notesList[index].priority),
            ),
            title: Text(this.notesList[index].title, style: titleStyle),
            subtitle: Text(this.notesList[index].description),
            // To detect delete Icon onTap Event
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey),
              onTap: () {
                _deleteNote(context, this.notesList[index]); // remove note
              },
            ),
            onTap: () {
              navigateToDetail(this.notesList[index], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      _updateListView();
    }
  }

  // returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.black;
        break;
      case 2:
        return Colors.amber;
        break;

      default:
        return Colors.amber;
    }
  }

  // get priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  // delete a note
  void _deleteNote(BuildContext ctx, Note note) async {
    int result = await _databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showMessage('Note Deleted Successfully');
      _updateListView();
    }
  }

  // display a message
  void _showMessage(String msg) {
    final snackBar = SnackBar(content: Text(msg));
    Scaffold.of(context).showSnackBar(snackBar);
  }

// update notes view
  void _updateListView() {
    final Future<Database> dbFuture = _databaseHelper.intitializeDatabase();
    dbFuture.then((database) {
      var noteListFuture = _databaseHelper.getNotesList();
      noteListFuture.then((noteList) {
        setState(() {
          this.notesList = noteList;
          this.notesCount = notesList.length;
        });
      });
    });
  }
}
