import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test")),
      body: Center(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("My test", style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 40
                ),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
