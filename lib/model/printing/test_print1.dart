import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utilities/basket_items.dart';



class PrintReceiptPage extends StatefulWidget {
  final List<BasketItem> basketItems;
  final String storeName;
  final String currency;
  PrintReceiptPage({required this.basketItems, required this.storeName, required this.currency});

  @override
  _PrintReceiptPageState createState() => _PrintReceiptPageState();
}

class _PrintReceiptPageState extends State<PrintReceiptPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();
  }

  Future<void> _getBluetoothDevices() async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    setState(() {
      _devices = devices;
    });
    _loadSelectedDevice();
  }

  Future<void> _loadSelectedDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceAddress = prefs.getString('selected_device');
    if (deviceAddress != null) {
      BluetoothDevice? device = _devices.firstWhere(
            (device) => device.address == deviceAddress,
        // orElse: () => null as BluetoothDevice?,
      );
      setState(() {
        _selectedDevice = device;
      });
      if (_selectedDevice != null) {
        _connectToDevice();
      }
    }
  }

  void _saveSelectedDevice(BluetoothDevice? device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (device != null) {
      prefs.setString('selected_device', device.address!);
    } else {
      prefs.remove('selected_device');
    }
  }

  void _connectToDevice() {
    if (_selectedDevice != null) {
      bluetooth.connect(_selectedDevice!).then((value) {
        setState(() {
          _connected = true;
        });
      }).catchError((error) {
        setState(() {
          _connected = false;
        });
      });
    }
  }

  void _printReceipt() {
    if (_connected) {
      double total = 0;

      bluetooth.printNewLine();
      bluetooth.printCustom(widget.storeName, 3, 1);
      bluetooth.printNewLine();

      for (var item in widget.basketItems) {
        double itemTotal = item.amount * item.quantity;
        total += itemTotal;
        bluetooth.printLeftRight("${item.name} x${item.quantity}", "${itemTotal.toStringAsFixed(2)}", 1);
      }

      bluetooth.printNewLine();
      bluetooth.printLeftRight("Total", "${widget.currency} ${total.toStringAsFixed(2)}", 3);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<BluetoothDevice>(
              hint: Text('Select Printer'),
              value: _selectedDevice,
              onChanged: (BluetoothDevice? device) {
                setState(() {
                  _selectedDevice = device;
                  _saveSelectedDevice(device);
                  _connectToDevice();
                });
              },
              items: _devices.map((BluetoothDevice device) {
                return DropdownMenuItem<BluetoothDevice>(
                  value: device,
                  child: Text(device.name!),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connected ? null : _connectToDevice,
              child: Text(_connected ? 'Connected' : 'Connect'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connected ? _printReceipt : null,
              child: Text('Print Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}