import 'dart:io';
import 'package:notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatebaseHelper
  static Database _database; //Singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDesc = 'description';
  String colPriority = 'priority';
  String colDate = 'date';
  DatabaseHelper._createInstance(); //Named Constructor to create instance of DatabaseHelper
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); //This extecute only once . Singleton Object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await intitializeDatabase();
    }
    return _database;
  }

  Future<Database> intitializeDatabase() async {
    // get Directory path for both Android and IOS
    Directory directory = await getApplicationDocumentsDirectory();

    String path = directory.path + "notes.db";

    var notesDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
        ' $colDesc TEXT,$colPriority INTEGER,$colDate TEXT)');
  }

  // Fetch All Notes
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    // var result =
    // await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert a Note
  Future<int> insertNote(Note note) async {
    Database db = await this.database;

    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update Note
  Future<int> updateNote(Note note) async {
    var db = await this.database;

    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete a note by id
  Future<int> deleteNote(int id) async {
    var db = await this.database;

    var result = db.rawDelete("DELETE FROM $noteTable WHERE $colId = $id");
    return result;
  }

  // Get  Number of Note  Objects in database
  Future<int> getNotesCount() async {
    var db = await this.database;

    List<Map<String, dynamic>> count =
        await db.rawQuery("SELECT COUNT (*) FROM $noteTable");
    int result = Sqflite.firstIntValue(count); // return size of Map objects
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to ' List<Note> ' [ List<Note> ]
  Future<List<Note>> getNotesList() async {
    var noteMapList = await getNoteMapList(); // get Map List from database
    int count = noteMapList.length; // count the number of map entries in table
    List<Note> notesList = List<Note>();

    // loop to create  List of Note
    for (int i = 0; i < count; i++) {
      notesList.add(Note.fromMapObject(noteMapList[i]));
    }

    return notesList;
  }
}
