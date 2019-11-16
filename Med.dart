import 'package:flutter/material.dart';

enum TakeMedResponse { TAKE_MED, NOT_YET, ITS_EXPIRED }

class Med {
  String _name;
  String _description;
  DateTime _expirationDate;
  DateTime _lastTimeTaken;
  int _timeBetweenUses; // in hours

  Med(this._name, this._description, this._expirationDate, this._lastTimeTaken,
      this._timeBetweenUses);

  _takeMed() {
    _lastTimeTaken = DateTime.now();
  }

  bool _isMedExpired() {
    if (_expirationDate.isBefore(DateTime.now())) return true;
    return false;
  }

  bool _isMedDue() {
    DateTime nextTakingTime =
        _lastTimeTaken.add(new Duration(hours: _timeBetweenUses));
    if (nextTakingTime.isBefore(DateTime.now())) return true;
    return false;
  }

  TakeMedResponse shouldTakeMed() {
    if (_isMedExpired()) return TakeMedResponse.ITS_EXPIRED;

    if (_isMedDue())
      return TakeMedResponse.TAKE_MED;
    else
      return TakeMedResponse.NOT_YET;
  }

  static Widget toWidget(Med med, Color color, bool verbose) {
    if (!verbose)
      return Column(children: [
        Align(
          alignment: FractionalOffset(0.1, 0),
          child: Text(
            med._name,
            style: TextStyle(color: color, fontSize: 24),
          ),
        ),
        SizedBox(height: 15.0),
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            med._description,
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
      ]);
    else {
      Duration timeLeft = med._lastTimeTaken.difference(DateTime.now());
      int days = timeLeft.inDays;
      int hours = timeLeft.inHours;
      int minutes = timeLeft.inMinutes % 60;
      int seconds = timeLeft.inSeconds % 60;
      String sTimeLeft = hours.toString() + ":" + minutes.toString() +
        ":" + seconds.toString();
      if(days == 1)
        sTimeLeft = days.toString() + "day - " + sTimeLeft;
      if(days > 1)
        sTimeLeft = days.toString() + "days - " + sTimeLeft;
      return Column(children: [
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            med._description,
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            "Expiration Date: " + med._expirationDate.toString(),
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            "Last time the medicine was taken: " +
                med._lastTimeTaken.toString(),
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            "Time until you should take it again: " + sTimeLeft,
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
      ]);
    }
  }

  static Color getColor(Med med) {
    TakeMedResponse resp = med.shouldTakeMed();
    switch(resp)
    {
      case TakeMedResponse.ITS_EXPIRED:
        return Colors.red[500];
      case TakeMedResponse.NOT_YET:
        return Colors.orange[300];
      case TakeMedResponse.TAKE_MED:
        return Colors.blue[500];
    }
    return Colors.black;
  }

  get name => _name;
  get expirationDate => _expirationDate;
  get lastTimeTaken => _lastTimeTaken;
  get timeBetweenUses => _timeBetweenUses;
  get description => _description;
}
