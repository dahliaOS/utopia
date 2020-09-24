import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_de/wm/window_entry.dart';
import 'package:flutter_de/wm/window_hierarchy.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<WindowHierarchyState> key = GlobalKey<WindowHierarchyState>();
  int windowIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WindowHierarchy(key: key),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          windowIndex++;

          key.currentState.pushWindowEntry(
            WindowEntry(
              title: "Window $windowIndex",
              content: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Text("Window $windowIndex"),
              ),
            ),
          );
        },
      ),
    );
  }
}
