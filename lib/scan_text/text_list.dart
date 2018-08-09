import 'package:camera_ml/scan_text/text_model.dart';
import 'package:flutter/material.dart';

class ScannedTextList extends StatelessWidget {
  final List<TextModel> scannedTexts;

  ScannedTextList({this.scannedTexts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Scanned Texts"),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    if (scannedTexts == null || scannedTexts.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No text found!'),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _ListItem(textModel: scannedTexts[index]);
        },
        itemCount: scannedTexts.length,
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final TextModel textModel;

  _ListItem({this.textModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        elevation: 2.0,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Text(textModel.text),
        ),
      ),
    );
  }
}
