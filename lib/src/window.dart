import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_entry.dart';
import 'package:wm/src/window_hierarchy.dart';
import 'package:wm/src/window_resize_gesture_detector.dart';
import 'package:wm/src/window_toolbar.dart';

class Window extends StatefulWidget {
  final Key key;
  final WindowEntry entry;
  final BoxConstraints constraints;

  Window({
    this.key,
    @required this.entry,
    this.constraints,
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entry.minimized) return Container();

    final hierarchy = context.watch<WindowHierarchyState>();

    Rect windowRect = widget.entry.maximized
        ? Rect.fromLTWH(
            0,
            0,
            widget.constraints.maxWidth,
            widget.constraints.maxHeight,
          )
        : Rect.fromLTWH(
            widget.entry.windowRect.left,
            widget.entry.windowRect.top,
            max(widget.entry.minSize.width, widget.entry.windowRect.width),
            max(widget.entry.minSize.height, widget.entry.windowRect.height),
          );

    return Positioned.fromRect(
      rect: windowRect,
      child: ChangeNotifierProvider<WindowEntry>.value(
        value: widget.entry,
        builder: (context, child) {
          final entry = context.watch<WindowEntry>();

          return RepaintBoundary(
            key: entry.renderBoundaryKey,
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
                    shape: entry.maximized
                        ? RoundedRectangleBorder()
                        : entry.shape,
                    clipBehavior: Clip.antiAlias,
                    elevation: entry.maximized ? 0 : entry.elevation,
                    color: entry.bgColor,
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        height:
                            max(entry.minSize.height, windowRect.size.height),
                        child: Column(
                          children: [
                            Visibility(
                              visible: entry.usesToolbar,
                              child: entry.toolbar ?? Container(),
                            ),
                            Expanded(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !entry.maximized && entry.allowResize,
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
      ),
    );
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
