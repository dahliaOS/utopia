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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowHierarchy(key: key),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          key.currentState.pushWindowEntry(
            WindowEntry(
              title: "Bruh",
              content: Container(
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}
