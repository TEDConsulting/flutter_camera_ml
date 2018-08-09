import 'package:flutter/material.dart';
import 'package:camera_ml/scan_barcode/barcode_model.dart';

class BarcodeList extends StatelessWidget {
  final List<BarcodeModel> barcodeList;

  BarcodeList({this.barcodeList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Scanned Barcodes"),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    if (barcodeList == null || barcodeList.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No barcodes found!'),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _ListItem(barcodeModel: barcodeList[index]);
        },
        itemCount: barcodeList.length,
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final BarcodeModel barcodeModel;

  _ListItem({this.barcodeModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        elevation: 2.0,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Text(barcodeModel.rawData),
        ),
      ),
    );
  }
}
