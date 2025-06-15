import 'package:flutter/material.dart';

import 'imbric.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Coratech Imbric'),
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
  Camion camion = Camion();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomPaint(
                size: Size.infinite,
                painter: MyPainter(camion),
            )
          ],
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Camion camion;

  MyPainter(this.camion);

  @override
  void paint(Canvas canvas, Size size) {

  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    return oldDelegate.camion != camion;
  }
}
