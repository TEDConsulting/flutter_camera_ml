import 'dart:io';
import 'package:camera_ml/common/rectangle_painter.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ScanFacesPage extends StatefulWidget {
  final File file;

  ScanFacesPage({this.file});

  @override
  State<StatefulWidget> createState() => ScanFacesPageState();
}

class ScanFacesPageState extends State<ScanFacesPage> {
  ImageInfo imageInfo;
  bool isFaceScanInitiated = false;
  bool isFaceScanComplete = false;
  String path;
  List<File> croppedImages = [];

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
    if (!isFaceScanInitiated) {
      isFaceScanInitiated = true;
      _findFaces();
    }
  }

  _findFaces() async {
    final FirebaseVisionImage image = FirebaseVisionImage.fromFile(widget.file);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    final List<Face> faces = await faceDetector.detectInImage(image);
    print('Highlighting faces');
    await _highlightFaces(faces);
    print(faces);
    setState(() {
      isFaceScanComplete = true;
    });
  }

  _highlightFaces(List<Face> faces) async {
    for (int i = 0; i < faces.length; i++) {
      print('Cropping face');
      var face = faces[i];
      int x = face.boundingBox.topLeft.x;
      int y = face.boundingBox.topLeft.y;
      int width = face.boundingBox.topLeft.x - face.boundingBox.topRight.x;
      int height = face.boundingBox.topRight.y - face.boundingBox.bottomRight.y;
      if (x < 0) x = 0;
      if (y < 0) y = 0;
      croppedImages.add(
        await FlutterNativeImage.cropImage(
          widget.file.path,
          x,
          y,
          width * -1,
          height * -1,
        ),
      );
    }
  }

  List<Widget> _buildStackChildren() {
    var widgets = <Widget>[];
    widgets.addAll([
      croppedImages.length == 0
          ? (Image.file(
              widget.file,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )..image.resolve(ImageConfiguration()).addListener(_resolveImage))
          : _buildPhotoGrid(),
      Positioned(
        bottom: 16.0,
        right: 40.0,
        left: 40.0,
        child: _buildAllTextButton(),
      ),
    ]);
    return widgets;
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .8,
      ),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(8.0),
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            elevation: 6.0,
            child: Image.file(
              croppedImages[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      itemCount: croppedImages.length,
    );
  }

//  _makeImage() async {
//    var byteData = await widget.file.readAsBytes();
//
//    var codec = await ui.instantiateImageCodec(byteData);
//    var nextFrame = await codec.getNextFrame();
//    image = nextFrame.image;
//
//    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
//    Canvas canvas = new Canvas(pictureRecorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(image.width.toDouble(), image.height.toDouble())));
//    RectanglePainter rectanglePainter = RectanglePainter(image: image);
//    rectanglePainter.paint(canvas, Size(image.width.toDouble(), image.height.toDouble()));
//    canvas.drawImage(image, Offset(0.0, 0.0), Paint()..color = Colors.grey);
//    canvas.drawRect(Rect.fromPoints(Offset(0.0, 0.0), Offset(image.width.toDouble() - 200.0, 200.0)), Paint()..color = Colors.green);
//    var pngImage = await pictureRecorder
//        .endRecording()
//        .toImage(image.width, image.height)
//        .toByteData(format: ui.ImageByteFormat.png);
//    Directory directory = await getTemporaryDirectory();
//    File pngFile = File(join(directory.path, "image.png"));
//    if (await pngFile.exists()) {
//      await pngFile.delete();
//      await pngFile.create();
//    }
//    print(pngFile.path);
//    await pngFile.writeAsBytes(pngImage.buffer.asUint8List(pngImage.offsetInBytes, pngImage.lengthInBytes));
//
//    print(await pngFile.length());
//    imageFile = pngFile;
//    print('Image Update');
//    setState(() {});
//  }

  Widget _buildAllTextButton() {
    return Material(
      elevation: 6.0,
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
      color: Colors.white,
      child: InkWell(
        onTap: isFaceScanComplete ? () {} : null,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: isFaceScanComplete
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${croppedImages.length} faces found',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
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
}
