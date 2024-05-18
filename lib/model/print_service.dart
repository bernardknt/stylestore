


import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class PrintService {
  ReceiptController? controller;

  Widget buildReceipt(BuildContext context){
    return Receipt(
      /// You can build your receipt widget that will be printed to the device
      /// Note that, this feature is in experimental, you should make sure your widgets will be fit on every device.
      builder: (context) => Column(
          children: [
            Text('Hello World'),
          ]
      ),
      onInitialized: (controller) {
        this.controller = controller;
      },
    );
  }
  Future<void> printNew(context) async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);

    if (device != null){
      print(device.address);
      String text = "Hello world";

      // Encode the text as UTF-8 to obtain byte data
      List<int> byteData = utf8.encode(text);

      List<int> dummyByteData = [
        137, 80, 78, 71, 13, 10, 26, 10, // PNG signature
      ];

      Future<BluetoothState> theState = FlutterBluetoothPrinter.getState();
      FlutterBluetoothPrinter.printBytes(address: device.address, data: Uint8List.fromList(byteData), keepConnected: true).catchError((onError){
        print(onError);
      })
          .whenComplete((){
            print("Printing Complete");
      });
      //
      // controller?.print(address: device.address);
      // print(theState);
    }else{
      print("Nothing");
    }
  }
}