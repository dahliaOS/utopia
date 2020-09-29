import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_entry.dart';
import 'package:wm/src/window_hierarchy.dart';
import 'package:wm/src/window_resize_gesture_detector.dart';

class Window extends StatefulWidget {
  final Key key;
  final WindowEntry entry;

  Window({
    this.key,
    @required this.entry,
  }) : super(key: key);

  _WindowState createState() => _WindowState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      entry.title;
}

class _WindowState extends State<Window> {
  static const double _resizingSpacing = 8;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final constraints =
          Provider.of<WindowHierarchyState>(context, listen: false).constraints;
      final offset = widget.entry.initiallyCenter
          ? Offset(
              (constraints.maxWidth / 2) - (widget.entry.initialSize.width / 2),
              (constraints.maxHeight / 2) -
                  (widget.entry.initialSize.height / 2),
            )
          : Offset.zero;
      widget.entry.windowRect = offset & widget.entry.initialSize;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WindowEntry>.value(
      value: widget.entry,
      builder: (context, child) {
        final entry = context.watch<WindowEntry>();
        final hierarchy = context.watch<WindowHierarchyState>();
        final constraints = hierarchy.constraints;

        if (entry.minimized) return Container();

        final docked = entry.maximized || entry.windowDock != WindowDock.NORMAL;

        Rect windowRect = entry.maximized
            ? Rect.fromLTWH(
                0,
                0,
                constraints.maxWidth,
                constraints.maxHeight,
              )
            : getRect(entry);

        return Positioned.fromRect(
          rect: windowRect,
          child: Stack(
            children: [
              GestureDetector(
                onPanStart: (details) {
                  hierarchy.requestWindowFocus(entry);
                  setState(() {});
                },
                onTapDown: (details) {
                  hierarchy.requestWindowFocus(entry);
                  setState(() {});
                },
                behavior: HitTestBehavior.translucent,
                child: Material(
                  shape: docked ? RoundedRectangleBorder() : entry.shape,
                  clipBehavior: Clip.antiAlias,
                  elevation: entry.maximized ? 0 : entry.elevation,
                  color: entry.bgColor,
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      height: max(entry.minSize.height, windowRect.size.height),
                      child: Column(
                        children: [
                          Visibility(
                            visible: entry.usesToolbar,
                            child: entry.toolbar ?? Container(),
                          ),
                          Expanded(
                            child: RepaintBoundary(
                              key: entry.repaintBoundaryKey,
                              child: MediaQuery(
                                data: MediaQueryData(
                                  size: Size(
                                    windowRect.width,
                                    windowRect.height - entry.minSize.height,
                                  ),
                                ),
                                child: ClipRect(
                                  child: entry.content,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !docked && entry.allowResize,
                child: WindowResizeGestureDetector(
                  borderThickness: _resizingSpacing,
                  listeners: _listeners,
                  onPanEnd: (details) {
                    entry.windowRect = Rect.fromLTWH(
                      entry.windowRect.left,
                      entry.windowRect.top,
                      max(entry.minSize.width, entry.windowRect.width),
                      max(entry.minSize.height, entry.windowRect.height),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Rect getRect(WindowEntry entry) {
    final hierarchy = context.read<WindowHierarchyState>();
    final constraints = hierarchy.constraints;

    switch (entry.windowDock) {
      case WindowDock.TOP_LEFT:
        return Rect.fromLTWH(
          0,
          0,
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
      case WindowDock.TOP:
        return Rect.fromLTWH(
          0,
          0,
          constraints.maxWidth,
          constraints.maxHeight / 2,
        );
      case WindowDock.TOP_RIGHT:
        return Rect.fromLTWH(
          constraints.maxWidth / 2,
          0,
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
      case WindowDock.LEFT:
        return Rect.fromLTWH(
          0,
          0,
          constraints.maxWidth / 2,
          constraints.maxHeight,
        );
      case WindowDock.RIGHT:
        return Rect.fromLTWH(
          constraints.maxWidth / 2,
          0,
          constraints.maxWidth / 2,
          constraints.maxHeight,
        );
      case WindowDock.BOTTOM_LEFT:
        return Rect.fromLTWH(
          0,
          constraints.maxHeight / 2,
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
      case WindowDock.BOTTOM:
        return Rect.fromLTWH(
          0,
          constraints.maxHeight / 2,
          constraints.maxWidth,
          constraints.maxHeight / 2,
        );
      case WindowDock.BOTTOM_RIGHT:
        return Rect.fromLTWH(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
      case WindowDock.NORMAL:
      default:
        return Rect.fromLTWH(
          entry.windowRect.left,
          max(0, entry.windowRect.top),
          max(entry.minSize.width, entry.windowRect.width),
          max(entry.minSize.height, entry.windowRect.height),
        );
    }
  }

  Map<Alignment, GestureDragUpdateCallback> get _listeners => {
        Alignment.topLeft: (details) =>
            _onPanUpdate(details, top: true, left: true),
        Alignment.topCenter: (details) => _onPanUpdate(details, top: true),
        Alignment.topRight: (details) =>
            _onPanUpdate(details, top: true, right: true),
        Alignment.centerLeft: (details) => _onPanUpdate(details, left: true),
        Alignment.centerRight: (details) => _onPanUpdate(details, right: true),
        Alignment.bottomLeft: (details) =>
            _onPanUpdate(details, bottom: true, left: true),
        Alignment.bottomCenter: (details) =>
            _onPanUpdate(details, bottom: true),
        Alignment.bottomRight: (details) =>
            _onPanUpdate(details, bottom: true, right: true),
      };

  void _onPanUpdate(
    DragUpdateDetails details, {
    bool left = false,
    bool top = false,
    bool right = false,
    bool bottom = false,
  }) {
    Provider.of<WindowHierarchyState>(context, listen: false)
        .requestWindowFocus(widget.entry);

    double _delta(bool apply, Axis axis) {
      double d = axis == Axis.horizontal ? details.delta.dx : details.delta.dy;
      return apply ? d : 0;
    }

    widget.entry.windowRect = Rect.fromLTRB(
      widget.entry.windowRect.left + _delta(left, Axis.horizontal),
      widget.entry.windowRect.top + _delta(top, Axis.vertical),
      widget.entry.windowRect.right + _delta(right, Axis.horizontal),
      widget.entry.windowRect.bottom + _delta(bottom, Axis.vertical),
    );

    setState(() {});
  }
}
