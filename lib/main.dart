import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Printer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PrinterScreen(),
    );
  }
}

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  static const platform = MethodChannel('com.example.flutter_printer_app/printer');

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _textToPrintController = TextEditingController();
  String _connectionStatus = 'Disconnected';
  List<Map<String, dynamic>> _pairedDevices = [];

  /// 🔹 Fetch paired Bluetooth devices
  Future<void> _getPairedDevices() async {
    // 🔹 Ask for runtime Bluetooth permissions
    if (await Permission.bluetoothConnect.request().isDenied) {
      _showSnackBar("Bluetooth permission is required");
      return;
    }
    if (await Permission.bluetoothScan.request().isDenied) {
      _showSnackBar("Bluetooth scan permission is required");
      return;
    }

    try {
      final List<dynamic> result =
      await platform.invokeMethod('getPairedBluetoothDevices');

      setState(() {
        _pairedDevices = result.map((e) {
          final map = Map<String, String>.from(e as Map);
          return {
            "name": map["name"] ?? "Unknown",
            "address": map["address"] ?? "",
          };
        }).toList();
      });
    } on PlatformException catch (e) {
      _showSnackBar("Error: ${e.message}");
    }
  }

  Future<void> _connectBluetoothPrinter() async {
    String address = _addressController.text;
    debugPrint("🔹 Trying to connect to Bluetooth printer: $address");

    try {
      final bool result = await platform.invokeMethod(
        'connectBluetoothPrinter',
        {'address': address},
      );
      debugPrint("✅ Bluetooth connect result: $result");

      setState(() {
        _connectionStatus = result ? 'Bluetooth Connected' : 'Failed to connect';
      });
    } on PlatformException catch (e) {
      debugPrint("❌ Bluetooth connection failed: ${e.message}");
      setState(() {
        _connectionStatus = "Failed: '${e.message}'";
      });
    }
  }

  Future<void> _connectUsbPrinter() async {
    debugPrint("🔹 Trying to connect to USB printer");

    try {
      final bool result = await platform.invokeMethod('connectUsbPrinter');
      debugPrint("✅ USB connect result: $result");

      setState(() {
        _connectionStatus = result ? 'USB Connected' : 'No USB printer found';
      });
    } on PlatformException catch (e) {
      debugPrint("❌ USB connection failed: ${e.message}");
      setState(() {
        _connectionStatus = "Failed: '${e.message}'";
      });
    }
  }

  Future<void> _printText() async {
    String text = _textToPrintController.text;
    debugPrint("🖨️ Sending text to print: $text");

    try {
      final bool result =
      await platform.invokeMethod('printText', {'text': text});
      debugPrint("✅ Print result: $result");

      if (result) {
        _showSnackBar('Print successful!');
      } else {
        _showSnackBar('Print failed!');
      }
    } on PlatformException catch (e) {
      debugPrint("❌ Print failed: ${e.message}");
      _showSnackBar("Error: '${e.message}'");
    }
  }

  Future<void> _closeConnection() async {
    debugPrint("🔹 Closing printer connection...");

    try {
      await platform.invokeMethod('closeConnection');
      debugPrint("✅ Connection closed successfully");

      setState(() {
        _connectionStatus = 'Disconnected';
      });
    } on PlatformException catch (e) {
      debugPrint("❌ Failed to close connection: ${e.message}");
      _showSnackBar("Error: '${e.message}'");
    }
  }

  void _showSnackBar(String message) {
    debugPrint("🔔 Snackbar: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                onPressed: _getPairedDevices,
                child: const Text('Get Paired Bluetooth Devices'),
              ),
              if (_pairedDevices.isNotEmpty)
                ..._pairedDevices.map((d) => ListTile(
                  title: Text(d["name"]!),
                  subtitle: Text(d["address"]!),
                  onTap: () {
                    setState(() {
                      _addressController.text = d["address"]!;
                    });
                  },
                )),
              const Divider(),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Bluetooth MAC Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _connectBluetoothPrinter,
                child: const Text('Connect Bluetooth Printer'),
              ),
              ElevatedButton(
                onPressed: _connectUsbPrinter,
                child: const Text('Connect USB Printer'),
              ),
              const SizedBox(height: 20),
              Text(
                'Status: $_connectionStatus',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textToPrintController,
                decoration: const InputDecoration(
                  labelText: 'Text to Print',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _printText,
                child: const Text('Print Text'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _closeConnection,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
                child: const Text('Close Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _textToPrintController.dispose();
    super.dispose();
  }
}
