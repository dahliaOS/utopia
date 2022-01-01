import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:example/shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
      ResizeWindowFeature(),
      FreeDragWindowFeature(),
    ],
    layoutInfo: FreeformLayoutInfo(
      size: Size(300, 300),
      position: Offset.zero,
    ),
    properties: {
      WindowEntry.title: "Clock widget",
      WindowEntry.icon: null,
      WindowEntry.showOnTaskbar: false,
      ResizeWindowFeature.minSize: Size(100, 100),
      ResizeWindowFeature.maxSize: Size(600, 600),
    },
  );
  static const toolbarEntry = WindowEntry(
    features: [],
    layoutInfo: FreeformLayoutInfo(
      size: Size.zero,
      position: Offset.zero,
      alwaysOnTop: true,
      alwaysOnTopMode: AlwaysOnTopMode.systemOverlay,
      fullscreen: true,
    ),
    properties: {
      WindowEntry.id: 'toolbar',
      WindowEntry.title: 'Shell toolbar',
      WindowEntry.icon: null,
      WindowEntry.showOnTaskbar: false,
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
          content: ClockWidget(
            globalSize: MediaQuery.of(context).size,
          ),
        ),
      );
      controller.addWindowEntry(
        toolbarEntry.newInstance(
          content: ChangeNotifierProvider.value(
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
      body: WindowHierarchy(
        controller: controller,
        layoutDelegate: const FreeformLayoutDelegate(),
      ),
      backgroundColor: Colors.black,
    );
  }
}

class StaggeredLayoutDelegate extends LayoutDelegate {
  const StaggeredLayoutDelegate();

  static const double half = 0.5;
  static const double third = 1 / 3;

  @override
  Widget layout(
    BuildContext context,
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  ) {
    if (entries.isEmpty) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final WindowHierarchyController hierarchy = WindowHierarchy.of(context);
        final List<MapEntry<int, double>> tiles;
        final int crossAxisCount;

        switch (entries.length) {
          case 1:
            crossAxisCount = 1;
            tiles = const [
              MapEntry(1, 1),
            ];
            break;
          case 2:
            crossAxisCount = 2;
            tiles = const [
              MapEntry(1, 1),
              MapEntry(1, 1),
            ];
            break;
          case 3:
            crossAxisCount = 2;
            tiles = const [
              MapEntry(1, 1),
              MapEntry(1, half),
              MapEntry(1, half),
            ];
            break;
          case 4:
            crossAxisCount = 2;
            tiles = const [
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
            ];
            break;
          case 5:
            crossAxisCount = 3;
            tiles = const [
              MapEntry(1, 1),
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
            ];
            break;
          case 6:
            crossAxisCount = 3;
            tiles = const [
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
              MapEntry(1, half),
            ];
            break;
          case 7:
            crossAxisCount = 3;
            tiles = const [
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(3, third),
            ];
            break;
          case 8:
            crossAxisCount = 6;
            tiles = const [
              MapEntry(2, third),
              MapEntry(2, third),
              MapEntry(2, third),
              MapEntry(2, third),
              MapEntry(2, third),
              MapEntry(2, third),
              MapEntry(3, third),
              MapEntry(3, third),
            ];
            break;
          case 9:
            crossAxisCount = 3;
            tiles = const [
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
              MapEntry(1, third),
            ];
            break;
          default:
            throw Exception(":(");
        }

        return StaggeredGrid.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          children: entries
              .mapIndexed(
                (index, e) => StaggeredGridTile.extent(
                  crossAxisCellCount: tiles[index].key,
                  mainAxisExtent:
                      tiles[index].value * hierarchy.wmBounds.height,
                  child: LayoutBuilder(
                    builder: (context, constraints) => MediaQuery(
                      data: MediaQueryData(size: constraints.smallest),
                      child: e.view,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
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
    final LayoutState layout = LayoutState.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        child: content,
        onPanUpdate: (details) {
          layout.position += details.delta;
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
