import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'armcontrolescreen.dart';

class SliderControlScreen extends StatefulWidget {
  final BluetoothDevice connectedDevice;
  const SliderControlScreen({Key? key, required this.connectedDevice})
      : super(key: key);

  @override
  _SliderControlScreenState createState() => _SliderControlScreenState();
}

class _SliderControlScreenState extends State<SliderControlScreen> {
  BluetoothCharacteristic? motorCharacteristic;
  double movementSliderValue = 0.0;
  double servoSliderValue = 90.0;
  bool isAutoMode = false;

  @override
  void initState() {
    super.initState();
    _findMotorCharacteristic();
  }

  void _findMotorCharacteristic() async {
    List<BluetoothService> services =
        await widget.connectedDevice.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            motorCharacteristic = characteristic;
          });
          break;
        }
      }
    }
  }

  String _getMovementCommand(double sliderPosition) {
    if (sliderPosition > 0) {
      if (sliderPosition < 100) return 'F';
      if (sliderPosition < 200) return 'B';
      return 'C';
    } else if (sliderPosition < 0) {
      if (sliderPosition > -100) return 'D';
      if (sliderPosition > -200) return 'E';
      return 'G';
    }
    return 'S';
  }

  String _getServoCommand(double angle) {
    if (angle == 0) return 'H';
    if (angle == 30) return 'I';
    if (angle == 60) return 'J';
    if (angle == 90) return 'K';
    if (angle == 120) return 'L';
    if (angle == 150) return 'M';
    if (angle == 180) return 'N';
    return 'K';
  }

  void _sendCommand(String command) async {
    if (motorCharacteristic != null) {
      try {
        await motorCharacteristic!.write(command.codeUnits);
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
        title: const Text('التحكم في السيارة',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Vertical Servo Control
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Row(
              children: [
                const RotatedBox(
                  quarterTurns: -1,
                  child: Text('زاوية التوجيه', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 15.0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 25.0),
                        trackHeight: 6.0,
                      ),
                      child: Slider(
                        value: servoSliderValue,
                        min: 0,
                        max: 180,
                        divisions: 6,
                        label: '${servoSliderValue.round()}°',
                        onChanged: (value) {
                          setState(() {
                            servoSliderValue = value;
                          });
                          _sendCommand(_getServoCommand(value));
                        },
                        onChangeEnd: (_) {
                          setState(() {
                            servoSliderValue = 90;
                          });
                          _sendCommand('K');
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Control Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arm Control Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArmControlScreen(
                        connectedDevice: widget.connectedDevice,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.blue,
                ),
                child: const Icon(Icons.precision_manufacturing,
                    size: 30, color: Colors.white),
              ),
              const SizedBox(width: 20),

              // Auto/Manual Mode Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAutoMode = !isAutoMode;
                    _sendCommand('*');
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: isAutoMode
                      ? Colors.green
                      : const Color.fromARGB(255, 2, 75, 134),
                ),
                child: Icon(
                  isAutoMode ? Icons.auto_mode : Icons.control_camera_rounded,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),

              // Additional Command Button
              ElevatedButton(
                onPressed: () => _sendCommand(')'),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.blue,
                ),
                child:
                    const Icon(Icons.bus_alert, size: 30, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Movement Slider
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Text('${movementSliderValue.round()}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 25.0),
                      trackHeight: 6.0,
                    ),
                    child: Slider(
                      value: movementSliderValue,
                      min: -255,
                      max: 255,
                      divisions: 6,
                      label: _getMovementCommand(movementSliderValue),
                      onChanged: (value) {
                        setState(() {
                          movementSliderValue = value;
                        });
                        _sendCommand(_getMovementCommand(value));
                      },
                      onChangeEnd: (_) {
                        setState(() {
                          movementSliderValue = 0;
                        });
                        _sendCommand('S');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
