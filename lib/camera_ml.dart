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
  ImageInfo imageInfo;
  final highlightedBoxes = <RectanglePainter>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Container(
      child: Stack(
        children: _buildStackChildren(),
      ),
    );
  }

  _resolveImage(ImageInfo info, bool _) {
    print(info.image.height);
    print(info.image.width);
    imageInfo = info;
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
        print(textLine.boundingBox.topLeft);
        highlightedBoxes.add(
          RectanglePainter(
            start: Offset(
              MediaQuery.of(context).size.width /
                  (imageInfo.image.width /
                      textLine.boundingBox.topLeft.x.toDouble()),
              MediaQuery.of(context).size.height /
                  (imageInfo.image.height /
                      textLine.boundingBox.topLeft.y.toDouble()),
            ),
            end: Offset(
              MediaQuery.of(context).size.width /
                  (imageInfo.image.width /
                      textLine.boundingBox.bottomRight.x.toDouble()),
              MediaQuery.of(context).size.height /
                  (imageInfo.image.height /
                      textLine.boundingBox.bottomRight.y.toDouble()),
            ),
          ),
        );
        setState(() {});
      });
    });
  }

  List<Widget> _buildStackChildren() {
    var widgets = <Widget>[];
    widgets.addAll([
      Image.file(
        widget.file,
        fit: BoxFit.fill,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      )..image.resolve(ImageConfiguration()).addListener(_resolveImage),
      Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: RaisedButton(
          child: Text('Find Text'),
          onPressed: _findText,
        ),
      ),
    ]);

    if (highlightedBoxes.isNotEmpty) {
      highlightedBoxes.forEach(
        (rectangle) {
          widgets.add(
            CustomPaint(
              painter: rectangle,
            ),
          );
        },
      );
    }

    return widgets;
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

class RectanglePainter extends CustomPainter {
  Offset start;
  final Offset end;

  RectanglePainter({
    this.start,
    this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    print('Painting');
    print(start);
    print(end);
    //start = Offset(100.0, 100.0);
    canvas.drawRect(
      Rect.fromPoints(start, end),
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
