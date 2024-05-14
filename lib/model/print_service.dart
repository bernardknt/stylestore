


import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class PrintService {
  ReceiptController? controller;
  // Future<void> printHelloWorld() async {
  //   // Get Bluetooth device
  //   final device = await FlutterBluetoothPrinter.selectDevice;
  //
  //   if (device != null) {
  //     // Connect to printer
  //     await FlutterBluetoothPrinter.connect(device);
  //
  //     // Print text
  //     await FlutterBluetoothPrinter.printString('Hello world!');
  //   } else {
  //     // Handle no device selected
  //     print("No printer selected");
  //   }
  // }

  Future<void> print(context) async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null){
      /// do print
      controller?.print(address: device.address);
    }
  }
}