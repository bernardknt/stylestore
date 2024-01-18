// import 'dart:io';
// import 'dart:typed_data';
// import 'package:blentit_kitchen/model/beautician_data.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
//
// class NewPrinter extends StatefulWidget {
//   static String id = 'new_printer';
//
//   @override
//   _NewPrinterState createState() => _NewPrinterState();
// }
//
// class _NewPrinterState extends State<NewPrinter> {
//   BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
//
//   List<BluetoothDevice> _devices = [];
//   BluetoothDevice _device;
//   bool _connected = false;
//   bool _pressed = false;
//   String pathImage;
//
//   initSavetoPath()async{
//     //read and write
//     //image max 300px X 300px
//     final filename = 'logo.png';
//     var bytes = await rootBundle.load("images/logo.png");
//     String dir = (await getApplicationDocumentsDirectory()).path;
//     writeToFile(bytes,'$dir/$filename');
//     setState(() {
//       pathImage='$dir/$filename';
//     });
//   }
//
//
//   Future<void> initPlatformState() async {
//     List<BluetoothDevice> devices = [];
//
//     try {
//       devices = await bluetooth.getBondedDevices();
//     } on PlatformException {
//       // TODO - Error
//     }
//
//     bluetooth.onStateChanged().listen((state) {
//       switch (state) {
//         case BlueThermalPrinter.CONNECTED:
//           setState(() {
//             _connected = true;
//             _pressed = false;
//           });
//           break;
//         case BlueThermalPrinter.DISCONNECTED:
//           setState(() {
//             _connected = false;
//             _pressed = false;
//           });
//           break;
//         default:
//           print(state);
//           break;
//       }
//     });
//
//     if (!mounted) return;
//     setState(() {
//       _devices = devices;
//     });
//   }
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     initSavetoPath();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Print Order'),
//         centerTitle: true,
//       ),
//       body: Container(
//         child: ListView(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Text(
//                     'Device:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   DropdownButton(
//                     items: _getDeviceItems(),
//                     onChanged: (value) => setState(() => _device = value),
//                     value: _device,
//                   ),
//                   ElevatedButton(
//                     onPressed:
//                     _pressed ? null : _connected ? _disconnect : _connect,
//                     child: Text(_connected ? 'Disconnect' : 'Connect'),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
//               child:  ElevatedButton(
//                 onPressed: _connected ? _testPrint : null,
//                 child: Text('Print'),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//     );
//   }
//
//
//   List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
//     List<DropdownMenuItem<BluetoothDevice>> items = [];
//     if (_devices.isEmpty) {
//       items.add(DropdownMenuItem(
//         child: Text('NONE'),
//       ));
//     } else {
//       _devices.forEach((device) {
//         items.add(DropdownMenuItem(
//           child: Text(device.name),
//           value: device,
//         ));
//       });
//     }
//     return items;
//   }
//
//   void _connect() {
//     if (_device == null) {
//       show('No device selected.');
//     } else {
//       bluetooth.isConnected.then((isConnected) {
//         if (!isConnected) {
//           bluetooth.connect(_device).catchError((error) {
//             setState(() => _pressed = false);
//           });
//           setState(() => _pressed = true);
//         }
//       });
//     }
//   }
//
//   void _disconnect() {
//     bluetooth.disconnect();
//     setState(() => _pressed = true);
//   }
//
// //write to app path
//   Future<void> writeToFile(ByteData data, String path) {
//     final buffer = data.buffer;
//     return new File(path).writeAsBytes(
//         buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
//   }
//
//   void _testPrint() async {
//     var kitchenData = Provider.of<KitchenData>(context);
//     //SIZE
//     // 0- normal size text
//     // 1- only bold text
//     // 2- bold with medium text
//     // 3- bold with large text
//     //ALIGN
//     // 0- ESC_ALIGN_LEFT
//     // 1- ESC_ALIGN_CENTER
//     // 2- ESC_ALIGN_RIGHT
//     bluetooth.isConnected.then((isConnected) {
//       if (isConnected) {
//         bluetooth.printNewLine();
//         bluetooth.printLeftRight("Order: ", kitchenData.orderNumber, 2);
//         // bluetooth.printCustom("Frutsexpress", 2, 1);
//         bluetooth.printNewLine();
//         bluetooth.printCustom(DateFormat('EEE-kk:mm aaa').format(kitchenData.deliveryTime), 2, 1);
//         bluetooth.printNewLine();
//         bluetooth.printCustom(kitchenData.clientName, 2, 1);
//         for(var i= 0; i< kitchenData.itemDetails.length; i++){
//           bluetooth.printNewLine();
//           bluetooth.printLeftRight("Order ${i+1}:", kitchenData.itemDetails[i], 1);
//         }
//         bluetooth.printNewLine();
//         bluetooth.printLeftRight("Note :", kitchenData.note, 1);
//         bluetooth.printNewLine();
//         bluetooth.printLeftRight("Location :",kitchenData.location, 1);
//         bluetooth.printNewLine();
//         // bluetooth.printLeftRight("Fee", kitchenData., 1);
//         bluetooth.printCustom("Thank You ...!", 3, 1);
//         bluetooth.printNewLine();
//         bluetooth.paperCut();
//       }else{
//         print(' No device connected');
//       }
//     });
//   }
//
//   Future show(
//       String message, {
//         Duration duration: const Duration(seconds: 3),
//       }) async {
//     await new Future.delayed(new Duration(milliseconds: 100));
//     Scaffold.of(context).showSnackBar(
//       new SnackBar(
//         content: new Text(
//           message,
//           style: new TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         duration: duration,
//       ),
//     );
//   }
// }


// bluetooth.isConnected.then((isConnected) {
// if (isConnected) {
// bluetooth.printNewLine();
// bluetooth.printLeftRight("Order: ", provider.orderNumber, 2);
// // bluetooth.printCustom("Frutsexpress", 2, 1);
// bluetooth.printNewLine();
// bluetooth.printCustom(DateFormat('EEE-kk:mm aaa').format(provider.deliveryTime), 2, 1);
// bluetooth.printNewLine();
// bluetooth.printCustom(provider.clientName, 2, 1);
// for(var i= 0; i< provider.itemDetails.length; i++){
// bluetooth.printNewLine();
// bluetooth.printLeftRight("Order ${i+1}:", '${provider.itemDetails[i]}', 1);
// }
// bluetooth.printNewLine();
// bluetooth.printLeftRight("Note :", provider.note, 1);
// bluetooth.printNewLine();
// bluetooth.printLeftRight("Location :",provider.location, 1);
// bluetooth.printNewLine();
// // bluetooth.printLeftRight("Fee", kitchenData., 1);
// // bluetooth.printCustom("Thank You ...!", 3, 1);
// bluetooth.printNewLine();
// bluetooth.paperCut();
// }