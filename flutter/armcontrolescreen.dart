import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ArmControlScreen extends StatefulWidget {
  final BluetoothDevice connectedDevice;
  const ArmControlScreen({Key? key, required this.connectedDevice})
      : super(key: key);

  @override
  _ArmControlScreenState createState() => _ArmControlScreenState();
}

class _ArmControlScreenState extends State<ArmControlScreen> {
  BluetoothCharacteristic? armCharacteristic;
  double servo1Value = 90.0; // Bottom-Right horizontal
  double servo2Value = 90.0; // Top-Left vertical
  double servo3Value = 90.0; // Bottom-Right vertical (above servo1)

  @override
  void initState() {
    super.initState();
    _findArmCharacteristic();
  }

  void _findArmCharacteristic() async {
    List<BluetoothService> services =
        await widget.connectedDevice.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            armCharacteristic = characteristic;
          });
          break;
        }
      }
    }
  }

  String _getServo1Command(double angle) {
    if (angle == 0) return 'Q'; // 0 درجة
    if (angle == 30) return 'R'; // 30 درجة
    if (angle == 60) return 'T'; // 60 درجة
    if (angle == 90) return 'U'; // 90 درجة
    if (angle == 120) return 'V'; // 120 درجة
    if (angle == 150) return 'W'; // 150 درجة
    if (angle == 180) return 'X'; // 180 درجة
    return 'U'; // Default 90 درجة
  }

  String _getServo2Command(double angle) {
    if (angle == 0) return 'Y'; // 0 درجة
    if (angle == 30) return 'Z'; // 30 درجة
    if (angle == 60) return '1'; // 60 درجة
    if (angle == 90) return '2'; // 90 درجة
    if (angle == 120) return '3'; // 120 درجة
    if (angle == 150) return '4'; // 150 درجة
    if (angle == 180) return '5'; // 180 درجة
    return '2'; // Default 90 درجة
  }

  String _getServo3Command(double angle) {
    if (angle == 0) return '6'; // 0 درجة
    if (angle == 30) return '7'; // 30 درجة
    if (angle == 60) return '8'; // 60 درجة
    if (angle == 90) return '9'; // 90 درجة
    if (angle == 120) return '@'; // 120 درجة
    if (angle == 150) return '#'; // 150 درجة
    if (angle == 180) return '='; // 180 درجة
    return '9'; // Default 90 درجة
  }

  void _sendCommand(String command) async {
    if (armCharacteristic != null) {
      try {
        await armCharacteristic!.write(command.codeUnits);
        print('Command Sent: $command');
      } catch (e) {
        print('Error sending command: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحكم في الذراع',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.blue[50]!],
          ),
        ),
        child: Stack(
          children: [
            // Servo 2 (Top-Left Vertical)
            Positioned(
              left: 20,
              top: 20,
              bottom: MediaQuery.of(context).size.height / 2,
              width: 100,
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 18),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 28),
                    trackHeight: 10.0,
                    activeTrackColor: Colors.blue[700],
                    thumbColor: Colors.blue[900],
                  ),
                  child: Slider(
                    value: servo2Value,
                    min: 0,
                    max: 180,
                    divisions: 6,
                    label: '${servo2Value.round()}°',
                    onChanged: (value) {
                      setState(() {
                        servo2Value = value;
                      });
                      _sendCommand(_getServo2Command(value));
                    },
                  ),
                ),
              ),
            ),

            // Vertical Buttons Column
            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.3, // Adjust position as needed
              right: MediaQuery.of(context).size.width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Water Drop Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: GestureDetector(
                      onTapDown: (_) => _sendCommand('A'),
                      onTapUp: (_) => _sendCommand('S'),
                      child: Container(
                        width: 90, // Reduced size
                        height: 90, // Reduced size
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.water_drop_outlined,
                              color: Colors.white,
                              size: 50), // Reduced icon size
                        ),
                      ),
                    ),
                  ),
                  // Replay Button
                  GestureDetector(
                    onTapDown: (_) => _sendCommand('P'),
                    onTapUp: (_) => _sendCommand('S'),
                    child: Container(
                      width: 90, // Reduced size
                      height: 90, // Reduced size
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.replay_circle_filled,
                            color: Colors.white, size: 50), // Reduced icon size
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom sliders container
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Servo 3 (horizontal)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 12),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 22),
                        trackHeight: 6.0,
                        activeTrackColor: Colors.blue[700],
                        thumbColor: Colors.blue[900],
                      ),
                      child: Slider(
                        value: servo3Value,
                        min: 0,
                        max: 180,
                        divisions: 6,
                        label: '${servo3Value.round()}°',
                        onChanged: (value) {
                          setState(() {
                            servo3Value = value;
                          });
                          _sendCommand(_getServo3Command(value));
                        },
                      ),
                    ),
                  ),

                  // Servo 1 (Bottom slider)
                  Container(
                    height: 60,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 15),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 25),
                        trackHeight: 8.0,
                        activeTrackColor: Colors.blue[700],
                        thumbColor: Colors.blue[900],
                      ),
                      child: Slider(
                        value: servo1Value,
                        min: 0,
                        max: 180,
                        divisions: 6,
                        label: '${servo1Value.round()}°',
                        onChanged: (value) {
                          setState(() {
                            servo1Value = value;
                          });
                          _sendCommand(_getServo1Command(value));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
