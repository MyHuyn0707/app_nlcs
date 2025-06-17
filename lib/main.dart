import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  late ImagePicker imagePicker;
  String result = "Result will be shown here";

  // TODO declare ImageLabeler
  late ImageLabeler imageLabeler;

  @override
  void initState()  {
    // TODO implement initState
    super.initState();
    imagePicker = ImagePicker();
    // TODO initialize labeler
    // final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
    // final imageLabeler = ImageLabeler(options: options);
    loadModel();
  }

  loadModel() async{
    final modelPath = await getModelPath('assets/ml/model_mobilenet_v2.tflite');
    final options = LocalLabelerOptions(
      confidenceThreshold: 0.5,
      modelPath: modelPath,
    );
    imageLabeler = ImageLabeler(options: options);
  }


  @override
  void dispose(){
    super.dispose();
  }


  // TODO choose image using gallery
  _imgFromGallery() async{
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if(image != null){
      _image = File(image.path);
      setState(() {
        _image;
        doImageLabeling();
      });
    }
  }

  // TODO capture image using camera
  _imgFromCamera() async{
    final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if(image != null){
      _image = File(image.path);
      setState(() {
        _image;
        doImageLabeling();
      });
    }
  }

  // TODO image labeling code here
  doImageLabeling() async{
    InputImage inputImage = InputImage.fromFile(_image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    String newResult = "";
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      newResult += "$text  ${confidence.toStringAsFixed(2)}\n";
    }

    setState(() {
      result = newResult;
    });

  }


  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover),
        ),
        child: Scaffold(
          body:  SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  width: 100,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Stack(children: <Widget>[
                    Stack(children: <Widget>[
                      Center(
                        child: Image.asset(
                          'assets/images/images.jpg',
                          height: 410,
                          width: 500,
                        ),
                      ),
                    ]),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent),
                        onPressed: _imgFromGallery,
                        onLongPress: _imgFromCamera,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: _image != null
                              ? Image.file(
                            _image!,
                            width: 335,
                            height: 495,
                            fit: BoxFit.fill,
                          )
                              : Container(
                            width: 340,
                            height: 330,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}






