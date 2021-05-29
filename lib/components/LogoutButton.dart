import 'package:flutter/material.dart';

//For AccountSettingsScreens
class LogoutButton extends StatelessWidget {

  final Function onPressed;
  const LogoutButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          "Logout",
          style: TextStyle(
              fontSize: 16.0,
              color: Colors.white
          ),
        ),
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.red[900]),
          backgroundColor: MaterialStateProperty.all(Colors.red),
          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0)),
        ),
      ),
      // margin: EdgeInsets.only(top: 30.0, bottom: 2.0),
    );
  }
}
