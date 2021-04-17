class Note {
  int _id;
  String _title;
  String _description;
  int _priority;
  String _date;

  Note(this._title, this._priority, this._date, [this._description]);

  Note.withId(this._id, this._title, this._priority, this._date,
      [this._description]);

  int get id => _id;

  String get title => _title;

  String get description => _description;

  String get date => _date;

  int get priority => _priority;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set description(String newDesc) {
    if (newDesc.length <= 255) {
      this._description = newDesc;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  // Convert Note into a map Object

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;
    return map;
  }

// Extract  Note Object from Map Object

  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }
}
