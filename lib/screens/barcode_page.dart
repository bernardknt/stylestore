



import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeScanPage extends StatelessWidget {
  Future<void> _startBarcodeScan(BuildContext context) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#FF0000", // Custom red color for the scanner
      "Cancel",   // Button text for cancelling the scan
      true,       // Show flash icon
      ScanMode.BARCODE, // Specify the scan mode (BARCODE, QR)
    );

    if (barcodeScanRes != '-1') {
      print(barcodeScanRes);
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Added $barcodeScanRes')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Barcode Scan Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startBarcodeScan(context),
              child: Text("Start Barcode Scan"),
            ),
          ],
        ),
      ),
    );
  }
}