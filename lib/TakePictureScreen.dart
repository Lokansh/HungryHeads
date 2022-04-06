import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:simple_s3/simple_s3.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/widgets/ValidationAlert.dart';
import 'package:camera/camera.dart';

// Future<void> upload(uploadImageURL) async {
//   // Ensure that plugin services are initialized so that `availableCameras()`
//   // can be called before `runApp()`
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Obtain a list of the available cameras on the device.
//   final cameras = await availableCameras();
//
//   // Get a specific camera from the list of available cameras.
//   final firstCamera = cameras.first;
//   print(firstCamera);
//   // runApp(
//   //   MaterialApp(
//   //     theme: ThemeData.dark(),
//   //     home: TakePictureScreen(
//   //       // Pass the appropriate camera to the TakePictureScreen widget.
//   //       camera: firstCamera,
//   //       uploadImageURL: uploadImageURL,
//   //     ),
//   //   ),
//   // );
//   Navigator.push(context, route)
// }

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen(
      {Key? key, required this.camera, required this.uploadImageURL})
      : super(key: key);

  final CameraDescription camera;
  final String uploadImageURL;

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
      body: Column(
        children: [
          FutureBuilder<void>(
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.teal),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back', style: TextStyle(fontSize: 20)),
          ),
        ],
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
                  uploadImageURL: widget.uploadImageURL,
                ),
              ),
            );
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
  final String uploadImageURL;

  const DisplayPictureScreen(
      {Key? key, required this.imagePath, required this.uploadImageURL})
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
              //upload to s3
              Uint8List bytes = await File(imagePath).readAsBytes();
              var response = await http.put(
                  Uri.parse(
                      uploadImageURL),
                  body: bytes);
              if (response.statusCode == 200) {
                ValidationAlert(message: "Uploaded successfully");
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (context) => testpage(),
                // ),);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
