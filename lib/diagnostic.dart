import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Diagnostic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
	  resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: Text('Diagnostic')),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatefulWidget {
	//CounterStorage get storage => new CounterStorage();

  BodyLayout({Key key}) : super(key: key);
  @override
  BodyLayoutState createState() {
    return new BodyLayoutState();
  }
}

class BodyLayoutState extends State<BodyLayout> {

  // The GlobalKey keeps track of the visible state of the list items
  // while they are being animated.
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
	print("""
found local path\n\n\n""");
    return File('$path/diagnostic.txt');
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

  //BodyLayoutState({Key key, @required this.storage}) : super(key: key);
  // backing data
  List<String> _data = [];

  @override
  void initState() {
    super.initState();
    readCounter().then((String value) {
      setState(() {
		  if ((value == null) == false){
			  print("value" + value);
			  _data = value.split("\n");
			  print("data ");print(_data);
			  for (int i = 0; i < _data.length; i++){
				  if (_data.elementAt(i) == " "){
					  continue;
				  }
				  _listKey.currentState.insertItem(i);
			  }
		  }
      });
    });
  }

  TextEditingController _textControllerAdd = TextEditingController();
  TextEditingController _textControllerRemove = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Container(
		child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
			children: <Widget>[
				SizedBox(height: 10.0),
				TextField(
					controller: _textControllerAdd,
					decoration: InputDecoration(
					hintText: 'Add diagnostic',
					),
				),
				RaisedButton(
				child: Text('Add diagnostic', style: TextStyle(fontSize: 10)),
				onPressed: () {
					_insertSingleItem();
				},
				),
				SizedBox(height: 10.0),
				TextField(
					controller: _textControllerRemove,
					decoration: InputDecoration(
					hintText: 'Remove diagnostic',
					),
				),
				RaisedButton(
				child: Text('Remove diagnostic', style: TextStyle(fontSize: 10)),
				onPressed: () {
					_removeSingleItem();
				},
				),
				SizedBox(
				height: 300,
				child: AnimatedList(
					// Give the Animated list the global key
					key: _listKey,
					initialItemCount: _data.length,
					// Similar to ListView itemBuilder, but AnimatedList has
					// an additional animation parameter.
					itemBuilder: (context, index, animation) {
					// Breaking the row widget out as a method so that we can
					// share it with the _removeSingleItem() method.
					return _buildItem(_data[index], animation);
					},
				),
				),
			],
		)
	);
}

  // This is the animated row with the Card.
  Widget _buildItem(String item, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          title: Text(
            item,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  void _insertSingleItem() {
	if (_textControllerAdd.text.isEmpty == false){
		int insertIndex = 0;
		if (_data.contains(_textControllerAdd.text.trim()) == false) {
		_data.add(_textControllerAdd.text.trim());
		_listKey.currentState.insertItem(insertIndex);
		_data.sort();

		var sb = new StringBuffer();

		for (int i = 0; i < _data.length - 1; i++){
			sb.writeln(_data.elementAt(i).trim());
		}
		sb.write(_data.elementAt(_data.length - 1).trim());

		String toWriteToFile = sb.toString();

		writeCounter(toWriteToFile);

		}
	}
  }

  void _removeSingleItem() {
    int removeIndex = _data.indexOf(_textControllerRemove.text.trim());
	if (removeIndex > -1){
		_data.remove(_textControllerRemove.text.trim());
		print("scot elem ");
		print(_data);

		AnimatedListRemovedItemBuilder builder = (context, animation) {
			return _buildItem(_textControllerRemove.text, animation);
			};
		// Remove the item visually from the AnimatedList.
		_listKey.currentState.removeItem(removeIndex, builder);
		var sb = new StringBuffer();

		for (int i = 0; i < _data.length - 1; i++){
			sb.writeln(_data.elementAt(i).trim());
		}
		sb.write(_data.elementAt(_data.length - 1).trim());

		String toWriteToFile = sb.toString();

		writeCounter(toWriteToFile);
	}
  }
}
