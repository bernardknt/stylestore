// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
//
// class PrintService {
//   Future<void> printData(String data) async {
//     // Check for already connected printer
//     final connectedDevice = await FlutterBluetoothPrinter.getState();
//
//     if (connectedDevice) {
//       // Print data if already connected
//       await _print(data);
//     } else {
//       // Scan for printers if not connected
//       final device = await FlutterBluetoothPrinter.selectDevice;
//
//       if (device != null) {
//         // Connect and print
//         await FlutterBluetoothPrinter.connect(device.address);
//         await _print(data);
//       } else {
//         // Handle no device selected
//         print("No printer selected");
//       }
//     }
//   }
//
//   Future<void> _print(String data) async {
//     // Convert data to bytes (consider ESC/POS commands for formatting)
//     final bytes = data.codeUnits;
//
//     // Print the bytes
//     await FlutterBluetoothPrinter.printBytes(bytes);
//   }
// }