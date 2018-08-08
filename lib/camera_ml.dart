import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class CameraMLPage extends StatefulWidget {
  final File file;

  CameraMLPage({
    @required this.file,
  }) : assert(file != null);

  @override
  State<StatefulWidget> createState() => CameraMLPageState();
}

class CameraMLPageState extends State<CameraMLPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Container(
      child: Stack(
        children: <Widget>[
          Image.file(
            widget.file,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: RaisedButton(
              child: Text('Find Text'),
              onPressed: _findText,
            ),
          ),
        ],
      ),
    );
  }

  _findText() async {
    final FirebaseVisionImage image = FirebaseVisionImage.fromFile(widget.file);
    final TextDetector textDetector = FirebaseVision.instance.textDetector();
    final List<TextBlock> textBlocks = await textDetector.detectInImage(image);
    _highlightText(textBlocks);
  }

  _highlightText(List<TextBlock> textBlocks) async {
    textBlocks.forEach((textBlock) {
      textBlock.lines.forEach((textLine) {
        print(textLine.text);
      });
    });
  }

  _findFaces() async {
    final FirebaseVisionImage image = FirebaseVisionImage.fromFile(widget.file);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    final List<Face> faces = await faceDetector.detectInImage(image);
    _highlightFaces(faces);
  }

  _highlightFaces(List<Face> faces) {
    if (faces != null) {
      faces.forEach((face) {
        FaceLandmark faceLandmark = face.getLandmark(FaceLandmarkType.leftEye);
      });
    }
  }
}
