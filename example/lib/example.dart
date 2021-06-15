import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm_new.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'monospace',
      ),
      debugShowCheckedModeBanner: false,
      shortcuts: const {},
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
    final registry = context.watch<WindowPropertyRegistry>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Example"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(MediaQuery.of(context).size.toString()),
            Text(MediaQuery.of(context).padding.toString()),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              child: const Text("Toggle resize ability"),
              onPressed: () {
                registry.resize.allowResize = !registry.resize.allowResize;
                setState(() {});
              },
            ),
            TextButton(
              child: const Text("Toggle always on top"),
              onPressed: () {
                registry.info.alwaysOnTop = !registry.info.alwaysOnTop;
                setState(() {});
              },
            ),
            TextButton(
              child: const Text("Spawn dialog"),
              onPressed: () {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => const AlertDialog(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
