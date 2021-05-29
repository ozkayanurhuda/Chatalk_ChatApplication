import 'package:flutter/material.dart';

import '../constants.dart';

//For AccountSettingsScreen
class UpdateButton extends StatelessWidget {

  final Function onPressed;
  const UpdateButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          "Update",
          style: TextStyle(fontSize: 16.0, color: white),
        ),
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(primaryColor),
          backgroundColor: MaterialStateProperty.all(greyColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0)),
        ),
      ),
      margin: EdgeInsets.only(top: 30.0, bottom: 2.0),
    );
  }
}
