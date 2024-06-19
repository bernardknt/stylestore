import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img; // Alias the image package
import 'package:ping_discover_network_plus/ping_discover_network_plus.dart';
import 'package:intl/intl.dart';

import '../../utilities/basket_items.dart';



class PrintReceiptPageEsc extends StatefulWidget {
  final List<BasketItem> basketItems;


  PrintReceiptPageEsc({required this.basketItems});

  @override
  _PrintReceiptPageEscState createState() => _PrintReceiptPageEscState();
}

class _PrintReceiptPageEscState extends State<PrintReceiptPageEsc> {
  String localIp = '';
  List<String> devices = [];
  String? _selectedDevice;
  bool isDiscovering = false;
  int found = -1;
  TextEditingController portController = TextEditingController(text: '9100');
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();
  }

  Future<void> _getBluetoothDevices() async {
    setState(() {
      isDiscovering = true;
      devices.clear();
      found = -1;
    });

    String ip;
    try {
      ip = '192.168.1.1'; // Assume an IP address for the example
      print('Local IP: $ip');
    } catch (e) {
      _showSnackbar('WiFi is not connected');
      return;
    }

    setState(() {
      localIp = ip;
    });

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;
    try {
      port = int.parse(portController.text);
    } catch (e) {
      portController.text = port.toString();
    }

    // final networkAnalyzer = NetworkAnalyzer(); // Create an instance of NetworkAnalyzer
    // final stream = networkAnalyzer.discover2(subnet, port);
    //
    // stream.listen((NetworkAddress addr) {
    //   if (addr.exists) {
    //     setState(() {
    //       devices.add(addr.ip);
    //       found = devices.length;
    //     });
    //   }
    // })
    //   ..onDone(() {
    //     setState(() {
    //       isDiscovering = false;
    //       found = devices.length;
    //     });
    //     _loadSelectedDevice();
    //   })
    //   ..onError((dynamic e) {
    //     _showSnackbar('Unexpected exception');
    //   });
  }

  Future<void> _loadSelectedDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceIp = prefs.getString('selected_device');
    if (deviceIp != null) {
      setState(() {
        _selectedDevice = deviceIp;
      });
    }
  }

  void _saveSelectedDevice(String? deviceIp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (deviceIp != null) {
      prefs.setString('selected_device', deviceIp);
    } else {
      prefs.remove('selected_device');
    }
  }

  void _showSnackbar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center)),
    );
  }

  Future<void> _printReceipt(String printerIp) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      final ByteData data = await rootBundle.load('assets/logo.png'); // Assume an asset image
      final Uint8List bytes = data.buffer.asUint8List();
      final img.Image? image = img.decodeImage(bytes); // Use the alias 'img'
      if (image != null) {
        printer.image(image);
      }

      printer.text('Example Store',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);

      printer.hr();
      printer.row([
        PosColumn(text: 'Qty', width: 1),
        PosColumn(text: 'Item', width: 7),
        PosColumn(
            text: 'Price',
            width: 2,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: 'Total',
            width: 2,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      double total = 0;
      for (var item in widget.basketItems) {
        double itemTotal = item.amount * item.quantity;
        total += itemTotal;
        printer.row([
          PosColumn(text: item.quantity.toString(), width: 1),
          PosColumn(text: item.name, width: 7),
          PosColumn(
              text: item.amount.toStringAsFixed(2),
              width: 2,
              styles: const PosStyles(align: PosAlign.right)),
          PosColumn(
              text: itemTotal.toStringAsFixed(2),
              width: 2,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      }

      printer.hr();
      printer.row([
        PosColumn(
            text: 'TOTAL',
            width: 6,
            styles: const PosStyles(
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            )),
        PosColumn(
            text: total.toStringAsFixed(2),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            )),
      ]);

      printer.hr(ch: '=', linesAfter: 1);

      final now = DateTime.now();
      final formatter = DateFormat('MM/dd/yyyy H:m');
      final String timestamp = formatter.format(now);
      printer.text('Thank you!',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.text(timestamp,
          styles: const PosStyles(align: PosAlign.center), linesAfter: 2);

      printer.feed(1);
      printer.cut();

      printer.disconnect();
    }

    _showSnackbar(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Print Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: 'Port',
              ),
            ),
            const SizedBox(height: 10),
            Text('Local ip: $localIp', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: isDiscovering ? null : () => _getBluetoothDevices(),
              child: Text(isDiscovering ? 'Discovering...' : 'Discover'),
            ),
            const SizedBox(height: 15),
            found >= 0
                ? Text('Found: $found device(s)', style: const TextStyle(fontSize: 16))
                : Container(),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDevice = devices[index];
                        _saveSelectedDevice(_selectedDevice);
                        _printReceipt(_selectedDevice!);
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 60,
                          padding: const EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.print),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${devices[index]}:${portController.text}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Click to print a test receipt',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}