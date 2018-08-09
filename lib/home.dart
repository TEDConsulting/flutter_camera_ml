import 'dart:io';

import 'package:camera_ml/scan_barcode/scan_barcode.dart';
import 'package:camera_ml/scan_faces/scan_faces.dart';
import 'package:camera_ml/scan_text/scan_text.dart';
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
        backgroundColor: Colors.white,
        elevation: 0.0,
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
        children: <Widget>[
          Expanded(
            child: _buildOptionCard(
              () => _startScanPage((context, file) => ScanTextPage(file: file)),
              const Color(0xFFA10BF4),
              const Color(0xFFCA6FF5),
              "Scan Text",
              Icons.format_color_text,
            ),
          ),
          Expanded(
            child: _buildOptionCard(
              () =>
                  _startScanPage((context, file) => ScanBarcodePage(file: file)),
              const Color(0xFF2D5E7D),
              const Color(0xFF417493),
              "Scan Barcodes",
              Icons.texture,
            ),
          ),
          Expanded(
            child: _buildOptionCard(
              () =>
                  _startScanPage((context, file) => ScanFacesPage(file: file)),
              Colors.orange[800],
              Colors.orange[400],
              "Find Faces",
              Icons.face,
            ),
          ),
        ],
      ),
    );
  }

  _startScanPage(StatefulWidget Function(BuildContext, File file) build) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return build(context, imageFile);
          },
        ),
      );
    }
  }

  Widget _buildOptionCard(
    VoidCallback onPressed,
    Color colorOne,
    Color colorSecond,
    String text,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          gradient: LinearGradient(
            end: Alignment.bottomRight,
            begin: Alignment.topLeft,
            colors: [
              colorOne,
              colorSecond,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorSecond,
              blurRadius: 3.0,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 40.0,
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
