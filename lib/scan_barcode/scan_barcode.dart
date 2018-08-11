import 'dart:io';
import 'package:camera_ml/scan_barcode/barcode_list.dart';
import 'package:camera_ml/scan_barcode/barcode_model.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class ScanBarcodePage extends StatefulWidget {
  final File file;

  ScanBarcodePage({
    @required this.file,
  }) : assert(file != null);

  @override
  State<StatefulWidget> createState() => ScanBarcodePageState();
}

class ScanBarcodePageState extends State<ScanBarcodePage> {
  ImageInfo imageInfo;
  bool isTextScanInitiated = false;
  bool isTextScanComplete = false;
  final scannedBarcodes = <BarcodeModel>[];

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
    BarcodeDetectorOptions options = BarcodeDetectorOptions(barcodeFormats: BarcodeFormat.all);
    final BarcodeDetector barcodeDetector =
        FirebaseVision.instance.barcodeDetector(options);
    final List<Barcode> barcodes = await barcodeDetector.detectInImage(image);
    print("Result Received");
    print(barcodes);
    if(barcodes != null && barcodes.isNotEmpty) {
      _highlightBarcodes(barcodes);
    }
    setState(() {
      isTextScanComplete = true;
    });
  }

  _highlightBarcodes(List<Barcode> barcodes) async {
    print("Looping barcodes");
    barcodes.forEach((barcode) {
      print("Adding barcode");
      scannedBarcodes.add(BarcodeModel(rawData: barcode.rawValue));
      print("Barcode added");
      setState(() {});
    });
    if (scannedBarcodes.isNotEmpty) {
      _showBarcodeList();
    }
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

    return widgets;
  }

  Widget _buildAllTextButton() {
    return Material(
      elevation: 6.0,
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
      color: Colors.white,
      child: InkWell(
        onTap: isTextScanComplete ? _showBarcodeList : null,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: isTextScanComplete
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        scannedBarcodes.length == 0 ? 'No Barcodes Found' : 'View Result',
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

  _showBarcodeList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BarcodeList(
            barcodeList: scannedBarcodes,
          );
        },
      ),
    );
  }
}
