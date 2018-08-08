import 'package:camera_ml/camera_ml.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera ML"),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text('Click Picture'),
            onPressed: _pickImageAndStart,
          ),
        ],
      ),
    );
  }

  _pickImageAndStart() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return CameraMLPage(file: imageFile);
          },
        ),
      );
    }
  }
}
