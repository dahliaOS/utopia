import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/example.dart';
import 'package:wm/src/window_entry.dart';
import 'package:wm/src/window_hierarchy.dart';
import 'package:wm/taskbar.dart';
import 'package:wm/wallpaper_layer.dart';
import 'package:wm/wm.dart';

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
        rootWindow: WallpaperLayer(),
        alwaysOnTopWindows: [
          Taskbar(
            alignment: TaskbarAlignment.LEFT,
            backgroundColor: Colors.white.withOpacity(0.7),
            itemColor: Colors.grey[900],
            leading: InkWell(
              child: SizedBox.fromSize(
                size: Size.square(48),
                child: Icon(
                  Icons.apps,
                  color: Colors.grey[900],
                ),
              ),
              onTap: () {
                key.currentState.pushWindowEntry(
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
                key.currentState.pushOverlayEntry(
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
                              bottom: key.currentState.insets.bottom + 16,
                              right: 16,
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
                    /*background: Builder(
                      builder: (context) {
                        final _ac =
                            context.watch<DismissibleOverlayEntry>().animation;
                        return BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 24,
                            sigmaY: 24,
                          ),
                          child: AnimatedBuilder(
                            animation: _ac,
                            builder: (context, _) {
                              return Material(
                                color: Colors.grey[900]
                                    .withOpacity(_ac.value * 0.7),
                              );
                            },
                          ),
                        );
                      },
                    ),*/
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
