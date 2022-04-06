import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/TakePictureScreen.dart';
import 'package:http/http.dart' as http;
import 'widgets/ValidationAlert.dart';
import 'package:camera/camera.dart';

class AddProduct extends StatelessWidget {
  const AddProduct({Key? key, required this.idToken, required this.username})
      : super(key: key);

  final String idToken;
  final String username;

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController notesController = TextEditingController();
    String image1URL = "";
    String image2URL = "";
    bool image1Added = false;
    bool image2Added = false;
    return Container(
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "Add New Product",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black45,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.create),
                      border: OutlineInputBorder(),
                      labelText: 'Product Name',
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                //   child: TextField(
                //     controller: notesController,
                //     decoration: const InputDecoration(
                //       prefixIcon: Icon(Icons.message),
                //       border: OutlineInputBorder(),
                //       labelText: 'Notes',
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.teal),
                    onPressed: () async {
                      if (nameController.text != "") {
                        if (image1URL == "") {
                          final getURLResponse = await getURL(idToken, {
                            "ItemName": nameController.text,
                            "User": username,
                            "Image1": true,
                            "Image2": true,
                          });
                          final body = jsonDecode(getURLResponse.body);
                          if (getURLResponse.statusCode == 200) {
                            image1Added = true;
                            upload(context, body["Image1"]);
                            image2URL = body["Image2"];
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => const ValidationAlert(
                                    message: "Something went wrong"));
                          }
                        } else {
                          image1Added = true;
                          upload(context, image1URL);
                        }
                        //body["Image2"]
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => const ValidationAlert(
                                message: "Provide valid details"));
                      }
                    },
                    child: const Text(
                      'Add Front Image',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.teal),
                    onPressed: () async {
                      if (nameController.text != "") {
                        if (image2URL == "") {
                          final getURLResponse = await getURL(idToken, {
                            "ItemName": nameController.text,
                            "User": username,
                            "Image1": true,
                            "Image2": true,
                          });
                          final body = jsonDecode(getURLResponse.body);
                          if (getURLResponse.statusCode == 200) {
                            image2Added = true;
                            upload(context, body["Image2"]);
                            image1URL = body["Image1"];
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => const ValidationAlert(
                                    message: "Something went wrong"));
                          }
                          //body["Image2"]
                        } else {
                          image2Added = true;
                          upload(context, image2URL);
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => const ValidationAlert(
                                message: "Provide valid details"));
                      }
                    },
                    child: const Text('Add Ingredients Image',
                        style: TextStyle(fontSize: 20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.teal),
                    onPressed: () {
                      if (image1Added && image2Added) {
                        nameController.text = "";
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Success'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        Text("Product Added Successfully!"),
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
                                ));
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => const ValidationAlert(
                                message: "Please add images"));
                      }
                    },
                    child: const Text('Done', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

Future<void> upload(context, uploadImageURL) async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  print(firstCamera);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TakePictureScreen(
        camera: firstCamera,
        uploadImageURL: uploadImageURL,
      ),
    ),
  );
}

Future<http.Response> getURL(String idToken, Object body) {
  return http.post(
    Uri.parse(
        'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/product/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': 'c5ec1kyeAD1GADOf9l1qR7lBJOjC8WSK26ryi0lE',
      'Auth': idToken
    },
    body: jsonEncode(body),
  );
}


Future<http.Response> removeFromWishlist(
    String idToken, Map<String, dynamic> params) {
  return http.delete(
      Uri.parse(
          'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/product/deleteWishlist')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': 'c5ec1kyeAD1GADOf9l1qR7lBJOjC8WSK26ryi0lE',
        'Auth': idToken
      });
}
