import 'package:flutter/material.dart';
class ValidationAlert extends StatelessWidget {
  const ValidationAlert({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Validation Error'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(message),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}