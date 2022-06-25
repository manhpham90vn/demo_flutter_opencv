import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const _MyHomePage(title: 'opencv_4 Demo'),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  File? _image;
  Uint8List? _byte;
  String _versionOpenCV = 'OpenCV';
  bool _visible = false;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getOpenCVVersion();
  }

  Future<void> _getOpenCVVersion() async {
    String? versionOpenCV = await Cv2.version();
    setState(() {
      _versionOpenCV = 'OpenCV: ${versionOpenCV!}';
    });
  }

  _testFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    _byte = await _image!.readAsBytes();

    setState(() {
      _byte;
      _visible = false;
    });
  }

  gaussianBlur() async {
    setState(() {
      _visible = true;
    });
    _byte = await Cv2.gaussianBlur(pathFrom: CVPathFrom.GALLERY_CAMERA, pathString: _image!.path, kernelSize: [101, 101], sigmaX: 0);
    setState(() {
      _byte;
      _visible = false;
    });
  }

  maskImage() async {
    setState(() {
      _visible = true;
    });
    _byte = await Cv2.filter2D(pathFrom: CVPathFrom.GALLERY_CAMERA, pathString: _image!.path, outputDepth: -1, kernelSize: [2, 2]);
    setState(() {
      _byte;
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        _versionOpenCV,
                        style: const TextStyle(fontSize: 23),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: _byte != null
                            ? Image.memory(
                          _byte!,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        )
                            : SizedBox(
                          width: 300,
                          height: 300,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Visibility(
                          maintainAnimation: true,
                          maintainState: true,
                          visible: _visible,
                          child:
                          const CircularProgressIndicator()),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextButton(
                          onPressed: _testFromCamera,
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.teal,
                            onSurface: Colors.grey,
                          ),
                          child: const Text('Take Photo'),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextButton(
                          onPressed: gaussianBlur,
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.teal,
                            onSurface: Colors.grey,
                          ),
                          child: const Text('Gaussian Blur'),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextButton(
                          onPressed: maskImage,
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.teal,
                            onSurface: Colors.grey,
                          ),
                          child: const Text('Mask Image'),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}