import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:simple_s3/simple_s3.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/widgets/ValidationAlert.dart';
import 'package:camera/camera.dart';

Future<void> upload(idToken) async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  print(firstCamera);
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
        idToken: idToken,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen(
      {Key? key, required this.camera, required this.idToken})
      : super(key: key);

  final CameraDescription camera;
  final String idToken;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

// returns url pointing to S3 file
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                  idToken: widget.idToken,
                ),
              ),
            );
            // SimpleS3 _simpleS3 = SimpleS3();
            // String result = await _simpleS3.uploadFile(
            //     File(image.path),
            //     "s3-bucket-s3bucket-1wjvsaapgbhy2",
            // "us-east-1:fe3e79db-abff-46d3-a6a3-a85bc99875c4",
            // AWSRegions.usEast1,
            //     fileName: "prashit.jpeg"
            // );
            // print(result);
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String idToken;

  const DisplayPictureScreen(
      {Key? key, required this.imagePath, required this.idToken})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: [
          Image.file(File(imagePath)),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final getURLResponse = await getURL(idToken, {
                "ItemName": "prashit",
                "User": "test flutter",
                "Image1": false,
                "Image2": true,
              });
              final body = jsonDecode(getURLResponse.body);
              //upload to s3
              Uint8List bytes = await File(imagePath).readAsBytes();
              print(body);
              var response = await http.put(
                  Uri.parse(
                      body["Image2"]),
                  body: bytes);
              if (response.statusCode == 200) {
                ValidationAlert(message: "Uploaded successfully");
                // Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
    );
  }
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
