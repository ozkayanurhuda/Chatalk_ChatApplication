import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 15.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Color(0xFFA34343)),
    ),
  );
}

linearProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 15.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
    ),
  );
}