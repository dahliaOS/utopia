import 'package:flutter/material.dart';
import 'package:utopia_wm/wm.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        fontFamily: 'Consolas',
      ),
      debugShowCheckedModeBanner: false,
      shortcuts: const {},
      home: const MyHomePage(),
      useInheritedMediaQuery: true,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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
    final WindowPropertyRegistry registry = WindowPropertyRegistry.of(context);
    final LayoutState layout = LayoutState.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Example"),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(MediaQuery.of(context).size.toString()),
            Text(MediaQuery.of(context).padding.toString()),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
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
                layout.alwaysOnTop = !layout.alwaysOnTop;
                setState(() {});
              },
            ),
            TextButton(
              child: const Text("Toggle fullscreen"),
              onPressed: () {
                layout.fullscreen = !layout.fullscreen;
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
