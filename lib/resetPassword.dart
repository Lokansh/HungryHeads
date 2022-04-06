import 'dart:convert';

import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'widgets/ValidationAlert.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({Key? key, required this.email, required this.destination}) : super(key: key);

  final String email;
  final String destination;
  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController rePasswordController = TextEditingController();
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
                  "Reset Password",
                  style: TextStyle(fontSize: 30, color: Colors.black45),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                          "Please enter the code sent to ${destination} and the new password."),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.key),
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                      TextField(
                        controller: rePasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.key),
                          border: OutlineInputBorder(),
                          labelText: 'Confirm Password',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.teal),
                    onPressed: () async {
                      if (codeController.text != "" &&
                          passwordController.text != "" &&
                          rePasswordController.text != "") {
                        if (!validatePassword(passwordController.text)) {
                          showDialog(
                              context: context,
                              builder: (context) => const ValidationAlert(
                                  message:
                                      "Password should contain: \n 1 uppercase letter \n 1 lowercase letter \n 1 special character \n 1 number \n 8 characters long"));
                        } else if (passwordController.text !=
                            rePasswordController.text) {
                          showDialog(
                              context: context,
                              builder: (context) => const ValidationAlert(
                                  message: "Password mismatch"));
                        } else {
                          final response = await confirmForgotPassword({
                            "email": email,
                            "password": passwordController.text,
                            "code": codeController.text
                          });
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
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => const ValidationAlert(
                                message: "Provide valid details"));
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool validatePassword(String value) {
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  Future<http.Response> confirmForgotPassword(Object body) {
    return http.post(
      Uri.parse(
          'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/user/confirmForgotPassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': 'c5ec1kyeAD1GADOf9l1qR7lBJOjC8WSK26ryi0lE'
      },
      body: jsonEncode(body),
    );
  }
}
