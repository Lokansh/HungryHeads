import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled/addProduct.dart';
import 'package:untitled/producthome.dart';
import 'package:untitled/widgets/ValidationAlert.dart';
import 'package:untitled/wishlist.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home(
      {Key? key,
      required this.username,
      required this.email,
      required this.accessToken,
      required this.idToken})
      : super(key: key);

  final String username;
  final String email;
  final String accessToken;
  final String idToken;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];
    void _showAction(BuildContext context, int index) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(_actionTitles[index]),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Welcome ${widget.username}'),
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
              final response =
                  await logout({"accessToken": widget.accessToken});
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
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            ProductHome(idToken: widget.idToken, username: widget.username,),
            AddProduct(idToken: widget.idToken, username: widget.username,),
            Wishlist(idToken: widget.idToken, username: widget.username,)
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
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