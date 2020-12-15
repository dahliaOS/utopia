import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm.dart';

import 'example.dart';
import 'taskbar.dart';
import 'wallpaper_layer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      color: Colors.black,
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
      backgroundColor: Colors.black,
      body: WindowHierarchy(
        key: key,
        rootWindow: WallpaperLayer(
          image: NetworkImage(
            "https://i.pinimg.com/originals/3b/8a/d2/3b8ad2c7b1be2caf24321c852103598a.jpg",
          ),
        ),
        alwaysOnTopWindows: [
          Taskbar(
            alignment: TaskbarAlignment.LEFT,
            backgroundColor: Colors.white.withOpacity(0.7),
            itemColor: Colors.grey[900]!,
            leading: InkWell(
              child: SizedBox.fromSize(
                size: Size.square(48),
                child: Icon(
                  Icons.apps,
                  color: Colors.grey[900],
                ),
              ),
              onTap: () {
                key.currentState!.pushWindowEntry(
                  WindowEntry.withDefaultToolbar(
                    icon: NetworkImage(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcR1HDcyXu9SHC4glO2kFKjVhcy9kU6Q1S9T2g&usqp=CAU",
                    ),
                    title: "Example",
                    toolbarColor: Colors.white,
                    content: ExampleApp(),
                  ),
                );
              },
            ),
            trailing: InkWell(
              child: SizedBox.fromSize(
                size: Size.square(48),
                child: Icon(
                  Icons.tune,
                  color: Colors.grey[900],
                ),
              ),
              onTap: () {
                key.currentState!.pushOverlayEntry(
                  DismissibleOverlayEntry(
                    uniqueId: "qs",
                    content: Builder(
                      builder: (context) {
                        final _ac =
                            context.watch<DismissibleOverlayEntry>().animation;
                        return AnimatedBuilder(
                          animation: _ac,
                          builder: (context, _) {
                            return Positioned(
                              bottom: key.currentState!.insets.bottom + 4,
                              right: 4,
                              width: _ac.value * 360,
                              height: _ac.value * 600,
                              child: Card(),
                            );
                          },
                        );
                      },
                    ),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.fastLinearToSlowEaseIn,
                    reverseCurve: Curves.fastOutSlowIn,
                  ),
                );
              },
            ),
          ),
        ],
        margin: EdgeInsets.only(
          bottom: 48,
        ),
      ),
    );
  }
}
