import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

List<Appointment> apList = [];
int id = 0;

List<Widget> wApList(List<Appointment> l, context) {
  List<Widget> newL = [];
  for (var i = 0; i < l.length; i++) {
    newL.add(l[i].toWidget(context));
  }
  return newL;
}

class Appointments extends StatefulWidget {
  Appointments({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _Appointments createState() => _Appointments();
}

class _Appointments extends State<Appointments> {
  Timer timer;

  void initState() {
    super.initState();
    readCounter().then((String contents) {
      //setState(() {
        if (contents == null) {
          apList = [];
        }
        else{
          apList = [];
          List<String> data = contents.split("\n");
          for (int i = 0; i < data.length; i=i+5) {
            apList.add(new Appointment(
              data[i],
              data[i+1],
              data[i+2],
              DateTime.parse(data[i+3]),
              int.parse(data[i+4])
            ));
          }
        }
      });
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) => setState((){}));
    //});
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/appointments.txt');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }

  void _addAppointment() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddAppointment(DateTime.now(), TimeOfDay.now(), '', '', '')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: wApList(apList, context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}

class SeeAppointmentDetails extends StatefulWidget {
  String name;
  String place;
  String other;
  DateTime time;
  int id;

  SeeAppointmentDetails(this.name, this.place, this.other, this.time, this.id);

  @override
  _SeeAppointmentDetails createState() =>
      _SeeAppointmentDetails(name, place, other, time, id);
}

class _SeeAppointmentDetails extends State<SeeAppointmentDetails> {
  String name;
  String place;
  String other;
  DateTime time;
  int id;

  _SeeAppointmentDetails(this.name, this.place, this.other, this.time, this.id);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print("""found local path\n\n\n""");
    return File('$path/appointments.txt');
  }

  Future<File> writeCounter(String list) async {
    final file = await _localFile;
    return file.writeAsString(list);
  }

  void rmAp() {
    for (var i = 0; i < apList.length; i++) {
      if (apList[i].id == id) {
        apList.removeAt(i);
        break;
      }
    }

    var sb = new StringBuffer();
    for(int i=0; i<apList.length; i++){
      sb.writeln(apList[i].name);
      sb.writeln(apList[i].place);
      sb.writeln(apList[i].other);
      sb.writeln(apList[i].time.toString());
      sb.writeln(apList[i].id.toString());
    }

    writeCounter(sb.toString());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$name'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15.0),
            Text(
              'Location:',
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              '$place',
              style: TextStyle(fontSize: 17.0),
            ),
            SizedBox(height: 15.0),
            Text(
              'On: $time',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 15.0),
            Text(
              'Details:',
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              '$other',
              style: TextStyle(fontSize: 17.0),
            ),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('Edit'),
                  onPressed: () {
                    rmAp();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddAppointment(
                                time,
                                TimeOfDay(hour: time.hour, minute: time.minute),
                                name,
                                place,
                                other)));
                  },
                ),
              ],
            ),
            SizedBox(height: 30.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              RaisedButton(
                child: Text('Remove'),
                onPressed: () {
                  rmAp();
                  Navigator.pop(context);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class Appointment {
  String name;
  String place;
  String other;
  DateTime time;
  int id;

  Appointment(this.name, this.place, this.other, this.time, this.id);

  Widget toWidget(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SeeAppointmentDetails(name, place, other, time, id)));
      },
      child: Text('$name'),
    );
  }
}

class AddAppointment extends StatefulWidget {
  @override
  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();
  String _name, _place, _other;

  AddAppointment(date, time, name, place, other) {
    _date = date;
    _time = time;
    _name = name;
    _place = place;
    _other = other;
  }

  _AddAppointment createState() =>
      _AddAppointment(_date, _time, _name, _place, _other);
}

class _AddAppointment extends State<AddAppointment> {
  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();
  DateFormat _dateFormat = DateFormat("yyyy-MM-dd");
  TextEditingController _textControllerName = TextEditingController();
  TextEditingController _textControllerPlace = TextEditingController();
  TextEditingController _textControllerOther = TextEditingController();

  String _dateStr = ' ', _timeStr = ' ';

  _AddAppointment(date, time, name, place, other) {
    _date = date;
    _time = time;
    _textControllerName.text = name;
    _textControllerPlace.text = place;
    _textControllerOther.text = other;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print("""found local path\n\n\n""");
    return File('$path/appointments.txt');
  }

  Future<File> writeCounter(String list) async {
    final file = await _localFile;
    return file.writeAsString(list);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2022));

    if (picked != null) {
      print('Selected: ${_date.toString()}');
      setState(() {
        _date = picked;
        _dateStr = _dateFormat.format(_date);
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null) {
      print('Selected: ${_time.toString()}');
      setState(() {
        _time = picked;
        _timeStr = picked.toString().substring(10, 15);
      });
    }
  }

  void _save() {
    String name = _textControllerName.text;
    String place = _textControllerPlace.text;
    String other = _textControllerOther.text;
    DateTime time = new DateTime(
        _date.year, _date.month, _date.day, _time.hour, _time.minute);

    if (name == '' || name == null) name = 'Appointment';
    if (place == '') place = '';
    if (other == '') other = '';

    Appointment ap = new Appointment(name, place, other, time, id);
    id = id + 1;
    apList.add(ap);
    Navigator.pop(context);

    var sb = new StringBuffer();
    for(int i=0; i<apList.length; i++){
      sb.writeln(apList[i].name);
      sb.writeln(apList[i].place);
      sb.writeln(apList[i].other);
      sb.writeln(apList[i].time.toString());
      sb.writeln(apList[i].id.toString());
    }

    writeCounter(sb.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Appointment'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15.0),
            Text(
              'Appointment name:',
              style: TextStyle(fontSize: 17.0),
            ),
            SizedBox(height: 5.0),
            TextField(
                controller: _textControllerName,
                decoration: InputDecoration(
                  hintText: 'Enter name',
                )),
            SizedBox(height: 20.0),
            Text(
              'Where?',
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
            SizedBox(height: 5.0),
            TextField(
                controller: _textControllerPlace,
                decoration: InputDecoration(
                  hintText: 'Enter address',
                )),
            SizedBox(height: 20.0),
            Text(
              'When?',
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
            SizedBox(height: 5.0),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: new Text('Select date'),
                  ),
                  SizedBox(width: 10.0),
                  Text('$_dateStr'),
                ]),
            SizedBox(height: 5.0),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      _selectTime(context);
                    },
                    child: new Text('Select time'),
                  ),
                  SizedBox(width: 10.0),
                  Text('$_timeStr'),
                ]),
            SizedBox(height: 20.0),
            Text(
              'Other information',
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
            SizedBox(height: 5.0),
            TextField(
              controller: _textControllerOther,
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    _save();
                  },
                  child: new Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
