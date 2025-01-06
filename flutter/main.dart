// main.dart
import 'package:flutter/material.dart';
import 'bluetooth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motor Control with Joystick',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BluetoothScreen(),
    );
  }
}
