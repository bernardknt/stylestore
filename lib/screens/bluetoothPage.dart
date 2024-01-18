// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:stylestore/Utilities/constants/color_constants.dart';
// import 'package:stylestore/model/common_functions.dart';
//
// import '../model/beautician_data.dart';
//
//
//
// class BluetoothPage extends StatefulWidget {
//   static String id = 'bluetooth_page';
//
//   @override
//
//
//   _BluetoothPageState createState() => new _BluetoothPageState();
//
// }
//
// class _BluetoothPageState extends State<BluetoothPage> {
//
//   BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
//
//
//   List<BluetoothDevice> _devices = [];
//    BluetoothDevice _device = BluetoothDevice("ios", "address");
//   bool _connected = false;
//   String pathImage = '';
//   //TestPrint testPrint;
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     initSavetoPath();
//     ///testPrint= TestPrint();
//   }
//
//   initSavetoPath()async{
//     //read and write
//     //image max 300px X 300px
//     final filename = 'yourlogo.png';
//     var bytes = await rootBundle.load("assets/images/yourlogo.png");
//     String dir = (await getApplicationDocumentsDirectory()).path;
//     writeToFile(bytes,'$dir/$filename');
//     setState(() {
//       pathImage='$dir/$filename';
//     });
//   }
//
//
//   Future<void> initPlatformState() async {
//     bool? isConnected = await bluetooth.isConnected;
//
//     // _device = (_devices.isNotEmpty ? _devices[0] : null)!; // Set to the first device if available.
//     List<BluetoothDevice> devices = [];
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
//           });
//           break;
//         case BlueThermalPrinter.DISCONNECTED:
//           setState(() {
//             _connected = false;
//           });
//           break;
//         default:
//           print("Current State Code: $state");
//           break;
//       }
//     });
//
//     if (!mounted) return;
//     setState(() {
//       _devices = devices;
//     });
//
//     if(isConnected!) {
//       setState(() {
//         _connected=true;
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     var kitchenData = Provider.of<BeauticianData>(context);
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Blue Thermal Printer'),
//         ),
//         body: Container(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ListView(
//               children: <Widget>[
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     SizedBox(width: 10,),
//                     Text(
//                       'Device:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(width: 30,),
//                     // Expanded(
//                     //   child:
//                     //
//                     //   DropdownButton(
//                     //     items: _getDeviceItems(),
//                     //     onChanged: (value) => setState(() =>
//                     //      print('YES')
//                     //     //   _device = value
//                     //     ),
//                     //     value: null
//                     //     // _device
//                     //     ,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//                 SizedBox(height: 10,),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: <Widget>[
//                     TextButton(
//                       // color: Colors.brown,
//                       style: ButtonStyle(backgroundColor: CommonFunctions().convertToMaterialStateProperty(kBlack)),
//                       onPressed:(){
//                         initPlatformState();
//                       },
//                       child: Text('Refresh', style: TextStyle(color: Colors.white),),
//                     ),
//                     SizedBox(width: 20,),
//                     TextButton(
//                       // color: _connected ?Colors.red:Colors.green,
//                       style: ButtonStyle(backgroundColor: CommonFunctions().convertToMaterialStateProperty(kBlack)),
//                       onPressed:
//                       _connected ? _disconnect : _connectToBluetooth,
//                       child: Text(_connected ? 'Disconnect' : 'Connect', style: TextStyle(color: Colors.white),),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
//                   child:
//                   TextButton(
//                     // color: Colors.brown,
//                     onPressed:(){
//                       //testPrint.sample(pathImage);
//                       print('ok');
//                     },
//                     child: Text('PRINT TEST', style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
//     List<DropdownMenuItem<BluetoothDevice>> items = [];
//     if (_devices.isEmpty) {
//       items.add(DropdownMenuItem(
//         child: Text('NONE'),
//         value: null, // Set the value to null when there are no devices.
//       ));
//     } else {
//       _devices.forEach((device) {
//         items.add(DropdownMenuItem(
//           child: Text(device.name!),
//           value: device, // Set the value to the BluetoothDevice.
//         ));
//       });
//     }
//     return items;
//   }
//
//   void _connectToBluetooth() {
//     if (_device == null) {
//       show('No device selected.');
//     } else {
//       bluetooth.isConnected.then((isConnected) {
//         if (isConnected!) {
//           bluetooth.connect(_device).catchError((error) {
//             setState(() => _connected = false);
//           });
//           setState(() => _connected = true);
//         }
//       });
//     }
//   }
//
//
//   void _disconnect() {
//     bluetooth.disconnect();
//     setState(() => _connected = true);
//   }
//
// //write to app path
//   Future<void> writeToFile(ByteData data, String path) {
//     final buffer = data.buffer;
//     return new File(path).writeAsBytes(
//         buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
//   }
//
//   Future show(
//       String message, {
//         Duration duration: const Duration(seconds: 3),
//       }) async {
//     await new Future.delayed(new Duration(milliseconds: 100));
//     // Scaffold.of(context).showSnackBar(
//     //   new SnackBar(
//     //     content: new Text(
//     //       message,
//     //       style: new TextStyle(
//     //         color: Colors.white,
//     //       ),
//     //     ),
//     //     duration: duration,
//     //   ),
//     // );
//   }
// }