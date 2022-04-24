import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:untitled/verification.dart';
import 'package:http/http.dart' as http;
import 'widgets/ValidationAlert.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController rePasswordController = TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('New Registration'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Sign up with email",
                  style: TextStyle(fontSize: 30, color: Colors.black45),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.account_circle_rounded),
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.teal),
                    onPressed: () async{
                      if (nameController.text != "" &&
                          emailController.text != "" &&
                          passwordController.text != "" &&
                          rePasswordController.text != "" ) {
                        if(!validateEmail(emailController.text)) {
                          showDialog(
                              context: context,
                              builder: (context) => const ValidationAlert(message: "Provide valid email"));
                        }
                        else if(!validatePassword(passwordController.text)) {
                          showDialog(
                              context: context,
                              builder: (context) => const ValidationAlert(message: "Password should contain: \n 1 uppercase letter \n 1 lowercase letter \n 1 special character \n 1 number \n 8 characters long"));
                        } else if (passwordController.text !=
                            rePasswordController.text) {
                          showDialog(
                              context: context,
                              builder: (context) => const ValidationAlert(message: "Password mismatch"));
                        } else {
                          final response = await signup({"email": emailController.text, "password": passwordController.text, "username": nameController.text});
                          final body = jsonDecode(response.body);
                          if(response.statusCode == 200) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Verification(email: nameController.text,),
                              ),
                            );
                          }
                          else {
                            showDialog(
                                context: context,
                                builder: (context) => ValidationAlert(message: body["message"]));
                          }
                        }
                      }
                      else {
                        showDialog(
                            context: context,
                            builder: (context) => const ValidationAlert(message: "Provide valid details"));
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
          // Column(
          //   children: [
          //     SignInButton(
          //       Buttons.GoogleDark,
          //       onPressed: () {},
          //     ),
          //     SignInButton(
          //       Buttons.AppleDark,
          //       onPressed: () {},
          //     ),
          //     SignInButton(
          //       Buttons.Facebook,
          //       onPressed: () {},
          //     ),
          //   ],
          // ),
        ]),
      ),
    );
  }

  bool validatePassword(String value) {
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool validateEmail(String value) {
    String  pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  Future<http.Response> signup(Object body) {
    return http.post(
      Uri.parse('https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/user/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': '****'
      },
      body: jsonEncode(body),
    );
  }
}
