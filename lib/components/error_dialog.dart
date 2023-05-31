import 'package:flutter/material.dart';

class ErrorDialog extends StatefulWidget {
  final String message;
  final Function tryAgainFunction;
  final Function okayFunction;

  const ErrorDialog({Key? key, required this.message, required this.tryAgainFunction, required this.okayFunction })
      : super(key: key);

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Error"),
      content: Text(widget.message),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            widget.okayFunction();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            primary: Colors.grey[400],
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          child: const Text(
            "Okay",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.tryAgainFunction();

          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            primary: const Color(0xFFFE9F24),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          child: const Text(
            'Try Again',
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
