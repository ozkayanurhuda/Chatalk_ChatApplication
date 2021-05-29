import 'package:flutter/material.dart';


//extract the login button then write my own vars
class RoundedButton extends StatelessWidget {

  final Color colour;
  final String title;
  final Function onPressed;
  RoundedButton({this.title, this.colour, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Material(
        elevation: 5.0,
        color:colour,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          //go to login screen.
          //Navigator.pushNamed(context, LoginScreen.id);
          minWidth: 200.0,
          height: 50.0,
          child: Text(title,
            style: TextStyle(
              fontSize: 17.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
