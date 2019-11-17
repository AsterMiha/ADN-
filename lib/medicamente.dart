import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:helloworld/Med.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';


enum ReadState {
  READING_NAME,
  READING_DESCRIPTION,
  READING_EXPIRATION,
  READING_LASTUSE,
  READING_TIMEBETWEEN
}

enum ViewState { VIEW_MEDS, CREATE_MEDS, VIEW_ONE_MED_DETAILED }

class AddRemoveListView extends StatefulWidget {
  _AddRemoveListViewState createState() => _AddRemoveListViewState();
}

class _AddRemoveListViewState extends State<AddRemoveListView> {
  TextEditingController _textController = TextEditingController();

  String name;
  String description;
  DateTime expiration;
  DateTime lastUse;
  int timeBetweenUses;

  Timer timer;

  ReadState state = ReadState.READING_NAME;
  List<String> originalHints = [
    "Enter Name",
    "Enter Description",
    "Enter Expiration Date",
    "Enter Last Use",
    "Enter Time Between Uses"
  ];

  List<String> buttonText = [
    "Submit Name",
    "Submit Description",
    "Submit Expiration Date",
    "Submit Last Use",
    "Submit Time Between Uses"
  ];

  List<String> currHints;
  int currIndex;

  List<Med> _listViewData = [];
  ViewState view;
  int medId;
  BuildContext context;

  int currNotificationId;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    _read();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);
    currNotificationId = 0;

    
    /*scheduleNotification("", " is due.", "Your medication needs attention.", 
        DateTime.now().add(new Duration(seconds: 5)));  
    currNotificationId++;*/ 

    currHints = originalHints;
    currIndex = 0;
    view = ViewState.VIEW_MEDS;
    medId = 0;
    timer = new Timer.periodic(Duration(seconds: 1), 
      (Timer t) => setState((){}));
  }

  Future onSelectNotification(String payload) {
    onReturnView();
    return null;
  }

  void scheduleNotification(String payload, String title, String body, 
    DateTime date) async {
    var android = new AndroidNotificationDetails('channel id', 'channel name', 'CHANNEL DESCRIPTION',
      importance: Importance.High, priority: Priority.High, ticker: 'ticker');
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    
    //debugPrint("*date = " + date.toString());
    currNotificationId = currNotificationId + 1;
    await flutterLocalNotificationsPlugin.schedule(
      currNotificationId++, title, body, date, platform, payload: payload,
      androidAllowWhileIdle: true);
  }

  void takeMed(){
    _listViewData[medId].takeMed();

    _save();

    Med med = _listViewData[medId];
    String tmpName = med.name;
    DateTime lastTimeUsed = med.lastTimeTaken;
    int timeBetween = med.timeBetweenUses;

    DateTime nextUse = lastTimeUsed.add(new Duration(hours: timeBetween));
    if(DateTime.now().isBefore(nextUse))
      scheduleNotification("", tmpName + " is due.", "Your medication needs attention.", nextUse);     
  }

  void onMedPressed(int id) {
    setState(() {
      view = ViewState.VIEW_ONE_MED_DETAILED;
      medId = id;
    });
  }

  void onRemoveMed() {
    setState(() {
      _listViewData.removeAt(medId);
      _save();
      onReturnView();
    });
  }

  void onResetReading() {
    setState(() {
      state = ReadState.READING_NAME;
      currIndex = 0;
      currHints = originalHints;
      medId = 0;
    });
  }

  void onTakeMed() {
    setState(() {
      if(_listViewData[medId].shouldTakeMed() == TakeMedResponse.TAKE_MED)
        takeMed();
      else
        promptAlertTakeMed(this.context);
    });
  }

  void promptAlertTakeMed(BuildContext context) {

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget acceptButton = FlatButton(
      child: Text("Do it anyway"),
      onPressed: () {
        takeMed();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    String textContent = "";
    TakeMedResponse response = _listViewData[medId].shouldTakeMed();
    if(response == TakeMedResponse.NOT_YET)
      textContent = "It is not yet time to take your medicine.";
    else
      textContent = "The medicine is expired!";

    AlertDialog alert = AlertDialog(
      title: Text("Attention!"),
      content: Text(textContent),
      actions: [
        cancelButton,
        acceptButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void onReturnCreate() {
    setState(() {
      view = ViewState.CREATE_MEDS;
    });
  }

  void onReturnView() {
    setState(() {
      view = ViewState.VIEW_MEDS;
    });
  }

  Widget getMeds() {
    List<Widget> result = new List<Widget>();
    result.add(SizedBox(height: 15.0, width: 5.0));
  
    for (int id = 0; id < _listViewData.length; id++) {
      int copyId = id;
      result.add(
        RaisedButton(
          onPressed: (() => onMedPressed(copyId)),
          child: Med.toWidget(_listViewData[copyId],
              Med.getColor(_listViewData[copyId]), false),
        ),
      );
      result.add(SizedBox(height: 15.0, width: 5.0));
    }
    return Expanded(
      child: ListView(padding: EdgeInsets.all(10.0), children: result),
    );
  }

  _onSubmit() {
    setState(() {
      switch (state) {
        case ReadState.READING_NAME:
          {
            String txt = _textController.text;
            _textController.clear();
            if (txt.length >= 50) {
              currHints[0] = "Please input shorter name";
              return;
            }

            if (txt.length <= 2) {
              currHints[0] = "Please input name with at least 3 characters.";
              return;
            }

            currIndex = 1;
            name = txt;
            state = ReadState.READING_DESCRIPTION;
          }
          break;
        case ReadState.READING_DESCRIPTION:
          {
            String txt = _textController.text;
            _textController.clear();
            if (txt.length >= 200) {
              state = ReadState.READING_EXPIRATION;
              currHints[1] = "Please input shorter description";
              return;
            }

            currIndex = 2;
            description = txt;
            state = ReadState.READING_EXPIRATION;
          }
          break;
        case ReadState.READING_EXPIRATION:
          {
            String txt = _textController.text;
            _textController.clear();

            DateTime expiration;
            try {
              expiration = DateTime.parse(txt);
            } on FormatException {
              currHints[2] = "Please use the format: 2012-02-27 13:27:00";
              return;
            }
            currIndex = 3;
            this.expiration = expiration;
            state = ReadState.READING_LASTUSE;
          }
          break;
        case ReadState.READING_LASTUSE:
          {
            String txt = _textController.text;
            _textController.clear();

            DateTime lastUse;
            try {
              lastUse = DateTime.parse(txt);
            } on FormatException {
              currHints[3] = "Please use the format: 2012-02-27 13:27:00";
              return;
            }
            currIndex = 4;
            this.lastUse = lastUse;
            state = ReadState.READING_TIMEBETWEEN;
          }
          break;
        case ReadState.READING_TIMEBETWEEN:
          {
            String txt = _textController.text;
            _textController.clear();

            int timeBetweenUses;
            try {
              timeBetweenUses = int.parse(txt);
            } on FormatException {
              currHints[4] = "Please enter a positive integer";
              return;
            }

            if (timeBetweenUses <= 0) {
              currHints[4] = "You entered an integer <= 0";
              return;
            }

            currIndex = 0;
            this.timeBetweenUses = timeBetweenUses;
            state = ReadState.READING_NAME;
            currHints = originalHints;
            _listViewData.add(new Med(
                name, description, expiration, lastUse, timeBetweenUses));
              
            _save();

            DateTime nextUse = lastUse.add(new Duration(hours: timeBetweenUses));
            scheduleNotification("", name + " has expired.", "Your medication needs attention.", expiration);
            if(DateTime.now().isBefore(nextUse))
              scheduleNotification("", name + " is due.", "Your medication needs attention.", nextUse);
          }
          break;
      }
    });
  }

  Widget getCreateView() {
    Color color = Colors.indigo;
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.add, 'ADD MED', onReturnCreate),
          _buildButtonColumn(
              color, Icons.remove_red_eye, 'VIEW MEDS', onReturnView),
          _buildButtonColumn(color, Icons.undo, 'UNDO SUBMISSIONS', onResetReading),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('Add medication'),
        ),
        body: Column(children: <Widget>[
          buttonSection,
          SizedBox(height: 15.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: currHints[currIndex],
                ),
              ),
            ),
            SizedBox(width: 20),
          ]),
          SizedBox(height: 15.0),
          Center(
            child: RaisedButton(
              onPressed: _onSubmit,
              child: Text(buttonText[currIndex]),
              color: Colors.red[500],
            ),
          ),
        ]));
  }

  Widget getDetailedMedView() {
    Color color = Colors.indigo;
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.add, 'ADD MED', onReturnCreate),
          _buildButtonColumn(
              color, Icons.remove_red_eye, 'VIEW MEDS', onReturnView),
          _buildButtonColumn(color, Icons.remove, 'REMOVE THIS', onRemoveMed),
          _buildButtonColumn(color, Icons.local_pharmacy, 'TAKE THIS', onTakeMed),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(_listViewData[medId].name),
        ),
        body: Column(children: <Widget>[
          buttonSection,
          SizedBox(height: 15.0),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10.0),
              children: [
                Med.toWidget(_listViewData[medId],
                    Med.getColor(_listViewData[medId]), true)
              ],
            ),
          )
        ]));
  }

  Widget getMedsView() {
    Color color = Colors.indigo;
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.add, 'ADD MED', onReturnCreate),
          _buildButtonColumn(
              color, Icons.remove_red_eye, 'VIEW MEDS', onReturnView),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('Current medication'),
        ),
        body: Column(children: <Widget>[
          buttonSection,
          getMeds(),
        ]));
  }

  Column _buildButtonColumn(
      Color color, IconData icon, String label, Function func) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: func,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    switch (view) {
      case ViewState.CREATE_MEDS:
        {
          return getCreateView();
        }
        break;
      case ViewState.VIEW_MEDS:
        {
          return getMedsView();
        }
        break;
      case ViewState.VIEW_ONE_MED_DETAILED:
        {
          return getDetailedMedView();
        }
        break;
    }
    return null;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/medicamente.txt');
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

  Future<File> writeCounter(String list) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(list);
  }

  void _save() {
    StringBuffer sb = new StringBuffer();

    List<Med> meds = new List.from(_listViewData);
    for (int id = 0; id < meds.length; id++) {
      Med med = meds[id];
      sb.writeln(med.name);
      sb.writeln(med.description);
      sb.writeln(med.expirationDate.toString());
      sb.writeln(med.lastTimeTaken.toString());
      sb.writeln(med.timeBetweenUses.toString());
    }

    writeCounter(sb.toString());
  }

   void _read() {
     _listViewData.clear();
    readCounter().then((String contents) {
      if(contents == null)
        return;
      else {
        List<String> data = contents.split("\n");
        for(int i = 0; i + 4 < data.length; i += 5)
        {
          Med med = new Med(data[i], data[i+1], DateTime.parse(data[i+2]),
            DateTime.parse(data[i+3]), int.parse(data[i+4]));
          _listViewData.add(med);
        }
      }
    });
  }

}