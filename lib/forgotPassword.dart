import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled/resetPassword.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'widgets/ValidationAlert.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
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
                  "Forgot Password",
                  style: TextStyle(fontSize: 30, color: Colors.black45),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                          "Please provide the registered email address to reset the password."),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.teal),
                  onPressed: () async {
                    if (emailController.text != "") {
                      final response = await forgotPasswordAPI(
                          {"email": emailController.text});
                      final body = jsonDecode(response.body);
                      if (response.statusCode == 200) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            ResetPassword(email: emailController.text, destination: body["CodeDeliveryDetails"]["Destination"],),
                          ),
                        );
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
                              message: "Provide valid email"));
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

  Future<http.Response> forgotPasswordAPI(Object body) {
    return http.post(
      Uri.parse(
          'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/user/forgotPassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': 'c5ec1kyeAD1GADOf9l1qR7lBJOjC8WSK26ryi0lE'
      },
      body: jsonEncode(body),
    );
  }
}
