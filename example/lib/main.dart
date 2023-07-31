import 'package:flutter/material.dart';
import 'package:gifx/gifx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gifx Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gifx Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = GifController();
  int frameCount = 0;
  Duration sourceDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Gif.asset(
            'images/test.gif',
            controller: _controller,
            // duration: const Duration(milliseconds: 3000),
          ),
          // Gif.network(
          //   'http://c-ssl.duitang.com/uploads/item/201803/26/20180326190951_QvM5V.thumb.1000_0.gif',
          //   controller: _controller,
          // ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _controller.play();
                },
                icon: const Icon(Icons.play_circle_fill_outlined),
                label: const Text('play'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _controller.stop();
                },
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('stop'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  frameCount = _controller.frameCount;
                  sourceDuration = _controller.sourceDuration;
                  setState(() {});
                },
                icon: const Icon(Icons.info_rounded),
                label: const Text('Get Info'),
              )
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Text('Frame Count: $frameCount'),
              const SizedBox(height: 10),
              Text('Source Duration: ${sourceDuration.inMilliseconds} ms'),
            ],
          )
        ],
      ),
    );
  }
}
