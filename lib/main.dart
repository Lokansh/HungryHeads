import 'package:flutter/material.dart';
import 'login.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hungry Heads',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const Login()
    );
  }
}