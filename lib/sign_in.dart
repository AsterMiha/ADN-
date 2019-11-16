import 'package:flutter/material.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
 
}

/*Widget showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }*/

class _SigninState extends State<Signin> {
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign in"),
      ),
      /*body: Stack(
        children: <Widget>[
            showForm(),
            showCircularProgress(),
        ],
      ),*/
    );
  }
}