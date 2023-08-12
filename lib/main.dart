import 'package:flutter/material.dart';
import 'package:camera/camera.dart'
    show
        CameraController,
        CameraDescription,
        FlashMode,
        ResolutionPreset,
        availableCameras;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linterna',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  const MyHomePage({required this.camera});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _controller;
  bool _isFlashOn = false;
  late Timer _timer;
  Color _currentColor = Colors.blue;
  List<Color> _lightColors = [Colors.red, Colors.blue];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
    );

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _toggleFlashlight() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _isFlashOn
          ? _controller.setFlashMode(FlashMode.torch)
          : _controller.setFlashMode(FlashMode.off);
    });
  }

  void _startLightsAnimation() {
    int index = 0;
    const duration = Duration(milliseconds: 500);
    _timer = Timer.periodic(duration, (Timer timer) {
      setState(() {
        _currentColor = _lightColors[index];
        index = (index + 1) % _lightColors.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Linterna'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.flash_on,
              size: 100,
              color: _isFlashOn ? Colors.yellow : Colors.grey,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleFlashlight,
              child: Text(
                _isFlashOn ? 'Apagar' : 'Encender',
                style: TextStyle(fontSize: 20),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 500,
              height: 400,
              decoration: BoxDecoration(
                color: _currentColor,
                shape: BoxShape.rectangle,
              ),
            ),
            ElevatedButton(
                onPressed: _startLightsAnimation,
                child: Text(
                  'Encender luces policiales',
                  style: TextStyle(fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }
}
