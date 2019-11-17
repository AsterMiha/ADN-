import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TakeMedResponse { TAKE_MED, NOT_YET, ITS_EXPIRED }

class Med {
  String _name;
  String _description;
  DateTime _expirationDate;
  DateTime _lastTimeTaken;
  int _timeBetweenUses; // in hours

  Med(this._name, this._description, this._expirationDate, this._lastTimeTaken,
      this._timeBetweenUses);

  void takeMed() {
    _lastTimeTaken = DateTime.now();
    //_makeTakeMedNotification();
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
      DateTime nextDate = med._lastTimeTaken.add(new Duration(hours: med._timeBetweenUses));
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
            "Expiration Date: " + new DateFormat.yMMMMEEEEd().format(med.expirationDate),
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            "Last time the medicine was taken: " +  new DateFormat.yMMMMEEEEd().format(med._lastTimeTaken) + " " +
                new DateFormat.Hms().format(med._lastTimeTaken),
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            "Time when you should take it again: " +  new DateFormat.yMMMMEEEEd().format(nextDate) + " " +
                new DateFormat.Hms().format(nextDate),
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
        Align(
          alignment: FractionalOffset(0.03, 0),
          child: Text(
            "Current date and time: " +  new DateFormat.yMMMMEEEEd().format(DateTime.now()) + " " +
                new DateFormat.Hms().format(DateTime.now()),
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        SizedBox(height: 15.0),
      ]);
    }
  }

  static Color getColor(Med med) {
    TakeMedResponse resp = med.shouldTakeMed();
    switch (resp) {
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
