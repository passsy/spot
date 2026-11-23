import 'package:flutter/material.dart';

class TimelineTestWidget extends StatefulWidget {
  const TimelineTestWidget({super.key});

  @override
  State<TimelineTestWidget> createState() => _TimelineTestWidgetState();
}

class _TimelineTestWidgetState extends State<TimelineTestWidget> {
  int _counter = 3;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _counter--;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _counter = 0;
                });
              },
            ),
          ],
        ),
        body: Center(child: Text('Counter: $_counter')),
      ),
    );
  }
}
