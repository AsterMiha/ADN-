import 'package:flutter/material.dart';
import 'package:helloworld/medicamente.dart';
import 'package:helloworld/programari.dart';
import 'package:helloworld/analize.dart';
import 'package:helloworld/diagnostic.dart';
import 'package:helloworld/alergii.dart';
import 'package:helloworld/sign_in.dart';
import 'package:helloworld/sign_up.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
      return new Scaffold(
        appBar: AppBar(
          title: new Text('Main'),
        ),
        body: new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              RaisedButton(
                padding: EdgeInsets.fromLTRB(10, 10, 285, 10),
                child: Text("Meds", style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  fontFamily: 'Roboto',
                ),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddRemoveListView()),);
                },
              ),

              RaisedButton(
                padding: EdgeInsets.fromLTRB(10, 10, 190, 10),
                child: Text("Appointments", style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  fontFamily: 'Roboto',
                ),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Appointments(title: "Appointments")),);
                },
              ),

              RaisedButton(
                padding: EdgeInsets.fromLTRB(10, 10, 215, 10),
                child: Text("Test results", style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  fontFamily: 'Roboto',
                ),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Analize()),);
                },
              ),

              RaisedButton(
                padding: EdgeInsets.fromLTRB(10, 10, 230, 10),
                child: Text("Diagnostic", style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  fontFamily: 'Roboto',
                ),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Diagnostic()),);
                },
              ),

              RaisedButton(
                padding: EdgeInsets.fromLTRB(10, 10, 250, 10),
                child: Text("Allergies", style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  fontFamily: 'Roboto',
                ),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Alergii()),);
                },
              ),

              SizedBox(height: 140,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                
                RaisedButton(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text("Sign in", style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    fontFamily: 'Roboto',
                  ),),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Signin()),);
                  },
                ),

                RaisedButton(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text("Sign up", style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    fontFamily: 'Roboto',
                  ),),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()),);
                  }, 
                ),],),
            ],
          ),
        ),
      );
  }
}