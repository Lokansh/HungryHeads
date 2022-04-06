import 'dart:convert';

import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'widgets/ValidationAlert.dart';

class Verification extends StatelessWidget {
  const Verification({Key? key, required this.email}) : super(key: key);

  final String email;
  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Hungry Heads")),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(child: Image.asset('assets/logo.png'), height: 150),
            Column(
              children: [
                const Text(
                  "Verification",
                  style: TextStyle(fontSize: 30, color: Colors.black45),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                          "A verification code is sent to your email account. Please enter the code below to complete sign up."),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.message),
                            border: OutlineInputBorder(),
                            labelText: 'Verification Code',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.teal),
                  onPressed: () async {
                    if (codeController.text != "") {
                      final response = await verification(
                          {"username": email, "code": codeController.text});
                      final body = jsonDecode(response.body);
                      if (response.statusCode == 200) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Success!'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        Text(body["message"]),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Ok'),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Login(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ));
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                ValidationAlert(message: body["message"]));
                      }
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => const ValidationAlert(
                              message: "Provide valid code"));
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> verification(Object body) {
    return http.post(
      Uri.parse(
          'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/user/verification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': 'c5ec1kyeAD1GADOf9l1qR7lBJOjC8WSK26ryi0lE'
      },
      body: jsonEncode(body),
    );
  }
}
