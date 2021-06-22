import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:example/shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm_new.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Consolas',
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          onSurface: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(0, 40),
            onSurface: Colors.white,
            side: const BorderSide(color: Colors.white),
          ),
        ),
      ),
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
  /* static const wallpaperEntry = WindowEntry(
    features: [WallpaperWindowFeature()],
    properties: {
      WindowEntry.title: "Wallpaper layer",
      WindowEntry.icon: null,
      WallpaperWindowFeature.IMAGE: NetworkImage(
          "https://assets.hongkiat.com/uploads/minimalist-dekstop-wallpapers/4k/original/18.jpg"),
    },
  ); */
  static const clockEntry = WindowEntry(
    features: [
      GeometryWindowFeature(),
      ResizeWindowFeature(),
      FreeDragWindowFeature(),
    ],
    properties: {
      WindowEntry.title: "Clock widget",
      WindowEntry.icon: null,
      WindowEntry.showOnTaskbar: false,
      GeometryWindowFeature.size: Size(300, 300),
      GeometryWindowFeature.position: Offset.zero,
      ResizeWindowFeature.minSize: Size(100, 100),
      ResizeWindowFeature.maxSize: Size(600, 600),
    },
  );
  static const toolbarEntry = WindowEntry(
    features: [],
    properties: {
      WindowEntry.id: 'toolbar',
      WindowEntry.title: 'Shell toolbar',
      WindowEntry.icon: null,
      WindowEntry.showOnTaskbar: false,
      WindowEntry.alwaysOnTop: true,
      WindowEntry.alwaysOnTopMode: AlwaysOnTopMode.systemOverlay,
    },
  );
  final WindowHierarchyController controller = WindowHierarchyController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      /* key.currentState?.addWindowEntry(
        wallpaperEntry.newInstance(null),
      ); */
      controller.addWindowEntry(
        clockEntry.newInstance(
          ClockWidget(
            globalSize: MediaQuery.of(context).size,
          ),
        ),
      );
      controller.addWindowEntry(
        toolbarEntry.newInstance(
          ChangeNotifierProvider.value(
            value: controller,
            child: const ShellDirector(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowHierarchy(controller: controller),
      backgroundColor: Colors.black,
    );
  }
}

class WallpaperWindowFeature extends WindowFeature {
  static const WindowPropertyKey<ImageProvider?> image =
      WindowPropertyKey("features.wallpaper.image", null);

  const WallpaperWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);

    final ImageProvider? image =
        properties.maybeGet(WallpaperWindowFeature.image);

    return SizedBox.expand(
      child: image != null
          ? Image(image: image, fit: BoxFit.cover)
          : const ColoredBox(color: Colors.black),
    );
  }

  @override
  List<WindowPropertyKey> get requiredProperties => [image];
}

class FreeDragWindowFeature extends WindowFeature {
  const FreeDragWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        child: content,
        onPanUpdate: (details) {
          properties.geometry.position += details.delta;
        },
      ),
    );
  }

  @override
  List<WindowPropertyKey> get requiredProperties => [];
}

class ClockWidget extends StatefulWidget {
  final Size globalSize;

  const ClockWidget({required this.globalSize, Key? key}) : super(key: key);

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime time;
  bool showTwoDots = true;

  @override
  void initState() {
    super.initState();
    time = DateTime.now();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      showTwoDots = !showTwoDots;
      time = DateTime.now();
      setState(() {});
    });
    /* WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final WindowPropertyRegistry properties =
          WindowPropertyRegistry.of(context, listen: false);

      properties.position =
          Offset(widget.globalSize.width - properties.size.width, 0);
    }); */
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: CustomPaint(
            painter: _ClockPainter(time: time),
            child: SizedBox.fromSize(
              size: Size.square(constraints.biggest.shortestSide),
            ),
          ),
        );
      },
    );
    /* return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: formatDigits(time.hour),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ":",
              style: TextStyle(
                color: showTwoDots ? null : Colors.transparent,
              ),
            ),
            TextSpan(text: formatDigits(time.minute)),
          ]),
          style: TextStyle(fontSize: 96, color: Colors.white),
        ),
      ),
    ); */
  }

  String formatDigits(int digits) {
    return [
      digits.toString().length == 1 ? "0" : "",
      digits.toString(),
    ].join();
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime time;

  const _ClockPainter({
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect boundingBox = Offset.zero & size;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Offset seconds = getAngleFromValue(time.second, 60);
    final Offset minutes = getAngleFromValue(time.minute, 60, time.second / 60);
    final Offset hours = getAngleFromValue(time.hour, 12, time.minute / 60, 25);

    drawWatchFace(canvas, size);

    canvas.drawOval(
      boundingBox,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawLine(
      center,
      center + seconds * (size.shortestSide / 2 * 0.8),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawLine(
      center,
      center + minutes * (size.shortestSide / 2 * 0.66),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawLine(
      center,
      center + hours * (size.shortestSide / 2 * 0.53),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  void drawWatchFace(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 60; i++) {
      final Offset point = getAngleFromValue(i, 60);
      final Offset pointLength =
          i % 5 == 0 ? point - (point / 12) : point - (point / 36);
      canvas.drawLine(
        center + point * (size.shortestSide / 2 * 0.95),
        center + pointLength * (size.shortestSide / 2 * 0.95),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
  }

  Offset getAngleFromValue(
    num value,
    double max, [
    num intervalFraction = 0,
    int intervalStep = 5,
  ]) {
    final double fraction = value / max;
    final double degrees =
        (fraction * 360 + (intervalFraction * intervalStep)) - 90;
    final double angle = degToRad(degrees);
    final double x = cos(angle);
    final double y = sin(angle);

    return Offset(x, y);
  }

  double degToRad(double deg) {
    return deg * pi / 180;
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) {
    return true;
  }
}
