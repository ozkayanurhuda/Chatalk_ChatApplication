import 'package:flutter/material.dart';

class EmojiTextButton extends StatelessWidget {

  final Function onPressed;
  final String stickerImage;
  const EmojiTextButton({Key key, @required this.onPressed, this.stickerImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.zero,
      child: TextButton(
        onPressed: onPressed,
        child: Image.asset(
          stickerImage,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
