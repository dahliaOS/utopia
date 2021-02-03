import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm.dart';

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      shortcuts: {},
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = context.watch<WindowEntry>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Example"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              MediaQuery.of(context).size.toString(),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              child: Text("Toggle toolbar"),
              onPressed: () {
                entry.usesToolbar = !entry.usesToolbar;
                setState(() {});
              },
            ),
            TextButton(
              child: Text("Change toolbar color"),
              onPressed: () {
                entry.toolbarColor = Colors
                    .primaries[Random().nextInt(Colors.primaries.length - 1)];
                setState(() {});
              },
            ),
            TextButton(
              child: Text("Spawn dialog"),
              onPressed: () {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => AlertDialog(
                    title: Text("Helo"),
                    content: Text("Yo"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
