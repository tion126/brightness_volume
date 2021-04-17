import 'package:flutter/material.dart';
import 'package:brightness_volume/brightness_volume.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double volume = 0.0;
  double brightness = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(children: [
          SizedBox(height: 100),
          Text("volume $volume"),
          Slider(value: volume, onChanged: (e){
            this.setState(() {
              this.volume = e;
              BVUtils.setVolume(e);
              this.p();
            });
          }),
          SizedBox(height: 100),
          Text("brightness $brightness"),
          Slider(value: brightness, onChanged: (e){
            this.setState(() {
              this.brightness = e;
              BVUtils.setBrightness(e);
              this.p();
            });
          })
        ])
      ),
    );
  }

  void p() async{
    var b = await BVUtils.brightness;
    var v = await BVUtils.volume;
    print("$b,$v");
  }
}
