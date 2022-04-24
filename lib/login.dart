import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled/forgotPassword.dart';
import 'package:untitled/verification.dart';
import 'home.dart';
import 'signup.dart';
import 'widgets/ValidationAlert.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
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
                  "Login",
                  style: TextStyle(fontSize: 30, color: Colors.black45),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            labelText: 'Email/Username',
                          ),
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.key),
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.teal),
                  onPressed: () async {
                    if (emailController.text != "" &&
                        passwordController.text != "") {
                      final response = await login({
                        "email": emailController.text,
                        "password": passwordController.text
                      });
                      final body = jsonDecode(response.body);
                      if (response.statusCode == 200) {
                        String accessToken =
                            body["AuthenticationResult"]["AccessToken"];
                        String idToken =
                            body["AuthenticationResult"]["IdToken"];
                        String name = body["Username"];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(
                              username: name,
                              email: emailController.text,
                              accessToken: accessToken,
                              idToken: idToken,
                            ),
                          ),
                        );
                      } else if (response.statusCode == 500 &&
                          body["message"] == "User is not confirmed.") {
                        final resendCodeResponse = await resendCode({
                          "email": emailController.text,
                        });
                        if (resendCodeResponse.statusCode == 200) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text('Confirm!'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: [
                                          const Text(
                                              "Please confirm your account"),
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
                                                  Verification(
                                                      email:
                                                          emailController.text),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ));
                        } else {
                          final resendCodeBody =
                              jsonDecode(resendCodeResponse.body);
                          showDialog(
                              context: context,
                              builder: (context) => ValidationAlert(
                                  message: resendCodeBody["message"]));
                        }
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
                              message: "Provide valid details"));
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
            Column(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                      primary: Colors.black45),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPassword(),
                      ),
                    );
                  },
                  child: const Text('Forgot Password'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                      primary: Colors.black45),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUp(),
                      ),
                    );
                  },
                  child: const Text('New User? Signup here'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> login(Object body) {
    return http.post(
      Uri.parse(
          'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': '****'
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> resendCode(Object body) {
    return http.post(
      Uri.parse(
          'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/user/resendCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': '****'
      },
      body: jsonEncode(body),
    );
  }
}
