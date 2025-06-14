import 'package:flutter/material.dart';

class MessageDisplay extends StatelessWidget {
  final String message;

  const MessageDisplay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Third of the size of the screen
      height: MediaQuery.of(context).size.height / 3,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
