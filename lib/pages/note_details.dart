import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper _dbHelper = DatabaseHelper();

  String appBarTitle;
  Note note;
  NoteDetailState(this.note, this.appBarTitle);
  static var _proirities = ['High', 'Low'];
  TextEditingController titleTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    titleTextController.text = note.title;
    descTextController.text = note.description;

    return WillPopScope(
        onWillPop: () async {
          navigateToPreviousPage();
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  navigateToPreviousPage();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.all(12),
            child: ListView(
              children: <Widget>[
                // EditText
                Padding(
                    padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
                    child: TextField(
                      controller: titleTextController,
                      style: TextStyle(fontStyle: FontStyle.normal),
                      onChanged: (value) {
                        debugPrint('Something changed');
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0))),
                    )),

// EditText
                Padding(
                    padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
                    child: TextField(
                      controller: descTextController,
                      style: TextStyle(fontStyle: FontStyle.normal),
                      onChanged: (value) {
                        debugPrint('Something changed');
                        updateDescription();
                      },
                      decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0))),
                    )),

                ListTile(
                  title: DropdownButton(
                      items: _proirities.map((String dropDownItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownItem,
                          child: Text(
                            dropDownItem,
                            style: TextStyle(
                                fontStyle: FontStyle.normal,
                                color: Colors.black),
                          ),
                        );
                      }).toList(),
                      style: TextStyle(fontStyle: FontStyle.normal),
                      value: getPriorityAsString(
                          note.priority), // get Priority As String
                      onChanged: (valueSelected) {
                        setState(() {
                          debugPrint('User Selected $valueSelected');
                          updatePriorityAsInt(
                              valueSelected); //  update note.priority By Selecetd Value
                        });
                      }),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Save button clicked');
                              onSaveClicked();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 6.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('delete button clicked');
                              _deleteNote();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void navigateToPreviousPage() {
    Navigator.pop(context,true);
  }

  // convert the String priority in to Integer before saving it in Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
      default:
        note.priority = 2;
    }
  }

  // convert int priority to string priority and display it in user dropDown
  String getPriorityAsString(int value) {
    switch (value) {
      case 1:
        return _proirities[0]; // ' High'
        break;

      case 2:
        return _proirities[1]; // 'Low'
        break;

      default:
        return _proirities[1];
    }
  }

  // update title in user Input
  void updateTitle() {
    note.title = titleTextController.text;
  }

  // upddte description in user input
  void updateDescription() {
    note.description = descTextController.text;
  }

  // save data to DB
  void onSaveClicked() async {
    navigateToPreviousPage();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // update opertion
      result = await _dbHelper.updateNote(note);
    } else {
      // insert operation
      result = await _dbHelper.insertNote(note);
    }

    if (result != 0) {
      // success
      _showMsg('status', 'Note saved successfully');
    } else {
      // failed
      _showMsg('status', 'Problem in saving note');
    }
  }

// show dialog
  void _showMsg(String status, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(status),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

// Delete note

  void _deleteNote() async {
    navigateToPreviousPage();

    int result = await _dbHelper.deleteNote(note.id);

    if (note.id == null) {
      _showMsg('status', 'Not is not created');
    }

    if (result != 0) {
      _showMsg('status', 'Note Deleted Successfully');
    } else {
      _showMsg('status', 'Error while delete note');
    }
  }
}
