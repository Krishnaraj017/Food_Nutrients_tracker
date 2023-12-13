import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:food/display.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraApp(),
    );
  }
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late XFile file;
  late CameraImage cameraImage;
  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      file = await controller.takePicture();
      // File is saved to file.path. You can handle the file as needed.

      //  handlig api call//
      final Uri apiUrl = Uri.parse('SERVER_API_ENDPOINT');
      var request = http.MultipartRequest('POST', apiUrl);

      var response = await request.send();
      if (response.statusCode == 200) {
        // Request was successful
        print('Image uploaded successfully');
      } else {
        // Request failed
        print('Failed to upload image. Status code: ${response.statusCode}');
      }

      print('Image saved to: ${file.path}');
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // File is picked from the gallery. You can handle the file as needed.
      print('Image picked from gallery: ${pickedFile.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
       
        body: Column(
          children: [
            Expanded(
              child: CameraPreview(controller),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _takePicture,
                  child: const Text('Take Picture'),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DisplayImageScreen(imagePath: file.path)));
                    },
                    child: Text('see taken pic')),
               
              ],
            ),
             ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Pick Image'),
        ),
          ],
        ));
  }
}
Future<void> _takePicture() async {
  try {
    file = await controller.takePicture();

    // Create a Dio instance
    Dio dio = Dio();

    // Create a FormData object to send the image file
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path, filename: 'image.jpg'),
    });

    // Replace 'YOUR_BACKEND_ENDPOINT' with your actual Node.js backend API endpoint
    String apiUrl = 'YOUR_BACKEND_ENDPOINT';

    // Send the image to the backend
    Response response = await dio.post(apiUrl, data: formData);

    if (response.statusCode == 200) {
      // Request was successful
      print('Image uploaded successfully');
    } else {
      // Request failed
      print('Failed to upload image. Status code: ${response.statusCode}');
    }

    print('Image saved to: ${file.path}');
  } catch (e) {
    print(e);
  }
}
