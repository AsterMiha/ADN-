import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_world/main.dart';
import 'package:flutter/foundation.dart';

enum ReadState{
  READING_NAME,
  READING_DESCRIPTION,
  READING_EXPIRATION,
  READING_LASTUSE,
  READING_TIMEBETWEEN
}

enum ViewState{
  VIEW_MEDS,
  CREATE_MEDS,
  VIEW_ONE_MED_DETAILED
}

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

  @override
  void initState() {
    super.initState();
    currHints = originalHints;
    currIndex = 0;
    view = ViewState.VIEW_MEDS;
    medId = 0;
    debugPrint('IM HERE');
  }

  void onMedPressed(int id) {
    setState(() {
      debugPrint('id = $id');
      debugPrint('medId = $medId');
      view = ViewState.VIEW_ONE_MED_DETAILED;
      medId = id;
      debugPrint('medId = $medId');
    });
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

    //int id = 0;
    //for(Med med in _listViewData)
    for(int id = 0; id < _listViewData.length; id++)
    {
      debugPrint('id = $id');
      int copyId = id;
      result.add(
        RaisedButton(
          onPressed: (() => onMedPressed(copyId)),
          child: Med.toWidget(_listViewData[copyId]),
        ),
      );
      result.add(SizedBox(height: 15.0, width: 5.0));
    }
    return Expanded( 
      child: ListView(
       padding: EdgeInsets.all(10.0),
       children: result
      ),
    );
  }

  _onSubmit() {
    setState(() {
    switch(state)
    {
      case ReadState.READING_NAME:
        {
          String txt = _textController.text;
          _textController.clear();
          if(txt.length >= 50)
          {
            currHints[0] = "Please input shorter name";
            return;
          }

          if(txt.length <= 2)
          {
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
          if(txt.length >= 200)
          {
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
          }
          on FormatException {
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
          }
          on FormatException {
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
          }
          on FormatException {
            currHints[4] = "Please enter a positive integer";
            return;
          }

          if(timeBetweenUses <= 0)
          {
            currHints[4] = "You entered an integer <= 0";
            return;
          }

          currIndex = 0;
          this.timeBetweenUses = timeBetweenUses;
          state = ReadState.READING_NAME;
          currHints = originalHints;
          _listViewData.add(new Med(name, description, expiration, lastUse,
            timeBetweenUses));
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
          _buildButtonColumn(color, Icons.remove_red_eye, 'VIEW MEDS', onReturnView),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Add medication'),
      ),
      body: Column(
        children: <Widget> [
          buttonSection,
          SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
            ]
          ),
          SizedBox(height: 15.0),
          Center(
            child: RaisedButton(
              onPressed: _onSubmit,
              child: Text(buttonText[currIndex]),
              color: Colors.red[500],
            ),
          ),
        ]
      )
    );
  }

  Widget getDetailedMedView() {
    Color color = Colors.indigo;
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.add, 'ADD MED', onReturnCreate),
          _buildButtonColumn(color, Icons.remove_red_eye, 'VIEW MEDS', onReturnView),
        ],
      ),
    );

    debugPrint('medId = $medId');
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),//Text(_listViewData[medId].name),
      ),
      body: Column(
        children: <Widget> [
          buttonSection,
          Med.toWidget(_listViewData[medId]),
        ]
      )
    );
  }

  Widget getMedsView() {
    Color color = Colors.indigo;
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.add, 'ADD MED', onReturnCreate),
          _buildButtonColumn(color, Icons.remove_red_eye, 'VIEW MEDS', onReturnView),
          //_buildButtonColumn(color, Icons.share, 'SHARE'),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Current medication'),
      ),
      body: Column(
        children: <Widget> [
          buttonSection,
          getMeds(),
        ]
      )
    );
  }

Column _buildButtonColumn(Color color, IconData icon, String label, Function func) {
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
    switch(view)
    {
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
}