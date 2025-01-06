import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'slidercontrolscreen.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  String _scanStatus = 'Press scan to find devices';
  List<ScanResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  Future<void> _checkBluetoothState() async {
    final isBluetoothOn = await FlutterBluePlus.isAvailable;
    if (!isBluetoothOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bluetooth is turned off. Please enable it.')),
      );
    }
  }

  Future<void> _requestPermissions() async {
    final permissionStatus = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    bool allGranted =
        permissionStatus.values.every((status) => status.isGranted);
    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some Bluetooth permissions are denied')),
      );
    }
  }

  void _startScan() async {
    await _requestPermissions();

    setState(() {
      _isScanning = true;
      _scanResults.clear();
      _scanStatus = 'Scanning for devices...';
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 20));

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
          _scanStatus = _scanResults.isEmpty
              ? 'No devices found. Try again.'
              : '${_scanResults.length} device(s) found';
        });
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanStatus = 'Scanning error: $e';
      });
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        _connectedDevice = device;
        _scanStatus = 'Connected to ${device.name}';
      });
    } catch (e) {
      setState(() {
        _scanStatus = 'Connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Connection')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isScanning ? null : _startScan,
            child: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
          ),
          Text(_scanStatus),
          Expanded(
            child: _scanResults.isEmpty
                ? const Center(child: Text('No devices discovered'))
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      return ListTile(
                        title: Text(result.device.name),
                        trailing: ElevatedButton(
                          onPressed: () => _connectToDevice(result.device),
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
          ),
          if (_connectedDevice != null)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SliderControlScreen(
                      connectedDevice: _connectedDevice!,
                    ),
                  ),
                );
              },
              child: const Text('Go to Control'),
            ),
        ],
      ),
    );
  }
}
