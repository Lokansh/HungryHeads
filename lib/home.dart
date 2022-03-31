import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled/upload.dart';
import 'package:untitled/widgets/ValidationAlert.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class Home extends StatelessWidget {
  const Home(
      {Key? key, required this.username, required this.email, required this.accessToken, required this.idToken})
      : super(key: key);

  final String username;
  final String email;
  final String accessToken;
  final String idToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome $username'),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app_sharp),
              onPressed: () async {
                final response = await logout({"accessToken": accessToken});
                final body = jsonDecode(response.body);
                print(body["message"]);
                if (response.statusCode == 200) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                } else {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          ValidationAlert(message: body["message"]));
                }
              },
            ),
          ],
        ),
        body: Container(
          child: IconButton(
            icon: const Icon(Icons.upload_sharp),
            onPressed: (){
              upload(idToken);
            },
          ),
        )
    );
  }
}

Future<http.Response> logout(Object body) {
  return http.post(
    Uri.parse(
        'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/user/logout'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': 'c5ec1kyeAD1GADOf9l1qR7lBJOjC8WSK26ryi0lE'
    },
    body: jsonEncode(body),
  );
}
