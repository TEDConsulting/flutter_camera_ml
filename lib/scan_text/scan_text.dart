import 'dart:io';
import 'package:camera_ml/scan_text/text_list.dart';
import 'package:camera_ml/scan_text/text_model.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class ScanTextPage extends StatefulWidget {
  final File file;

  ScanTextPage({
    @required this.file,
  }) : assert(file != null);

  @override
  State<StatefulWidget> createState() => CameraMLPageState();
}

class CameraMLPageState extends State<ScanTextPage> {
  ImageInfo imageInfo;
  final highlightedBoxes = <RectanglePainter>[];
  bool isTextScanInitiated = false;
  bool isTextScanComplete = false;
  final scannedTexts = <TextModel>[];

  @override
  void initState() {
    super.initState();
  }

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
    if (!isTextScanInitiated) {
      isTextScanInitiated = true;
      _findText();
    }
  }

  _findText() async {
    final FirebaseVisionImage image = FirebaseVisionImage.fromFile(widget.file);
    final TextDetector textDetector = FirebaseVision.instance.textDetector();
    final List<TextBlock> textBlocks = await textDetector.detectInImage(image);
    _highlightText(textBlocks);
    setState(() {
      isTextScanComplete = true;
    });
  }

  _highlightText(List<TextBlock> textBlocks) async {
    textBlocks.forEach((textBlock) {
      textBlock.lines.forEach((textLine) {
        scannedTexts.add(
          TextModel(
            text: textLine.text,
          ),
        );

        print(textLine.text);
        print(textLine.boundingBox.topLeft);
        highlightedBoxes.add(
          RectanglePainter(
            text: textLine.text,
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
        bottom: 16.0,
        right: 40.0,
        left: 40.0,
        child: _buildAllTextButton(),
      )
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

  Widget _buildAllTextButton() {
    return Material(
      elevation: 6.0,
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
      color: Colors.white,
      child: InkWell(
        onTap: isTextScanComplete ? _startScannedTextPage : null,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: isTextScanComplete
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'See All Scanned Texts',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  )
                : SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
      ),
    );
  }

  _startScannedTextPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ScannedTextList(
            scannedTexts: scannedTexts,
          );
        },
      ),
    );
  }
}

class RectanglePainter extends CustomPainter {
  Offset start;
  final Offset end;
  final String text;

  RectanglePainter({
    this.start,
    this.end,
    this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromPoints(start, end),
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    TextSpan textSpan = TextSpan(
      style: TextStyle(
        color: Colors.green,
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
      ),
      text: text,
    );

    //Draw text
    TextPainter tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(start.dx, end.dy));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
