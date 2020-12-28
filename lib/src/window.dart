import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/window_entry.dart';
import 'package:utopia_wm/src/window_hierarchy.dart';
import 'package:utopia_wm/src/window_resize_gesture_detector.dart';

class Window extends StatefulWidget {
  final Key? key;
  final WindowEntry entry;

  Window({
    this.key,
    required this.entry,
  }) : super(key: key);

  _WindowState createState() => _WindowState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      entry.title ?? "";
}

class _WindowState extends State<Window> {
  static const double _resizingSpacing = 8;

  @override
  void initState() {
    final hierarchy = Provider.of<WindowHierarchyState>(context, listen: false);
    final wmRect = hierarchy.wmRect;
    final offset = widget.entry.initiallyCenter
        ? Offset(
            wmRect.top +
                (wmRect.width / 2) -
                (widget.entry.initialSize.width / 2),
            wmRect.left +
                (wmRect.height / 2) -
                (widget.entry.initialSize.height / 2),
          )
        : Offset.zero;
    widget.entry.windowRect = offset & widget.entry.initialSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mobileWindow = MediaQuery.of(context).size.width < 480;
    return ChangeNotifierProvider<WindowEntry>.value(
      value: widget.entry,
      builder: (context, child) {
        final entry = context.watch<WindowEntry>();
        final hierarchy = context.watch<WindowHierarchyState>();

        final docked = entry.maximized ||
            entry.windowDock != WindowDock.NORMAL ||
            mobileWindow;

        Rect windowRect = getRect(entry, mobileWindow);

        return Positioned.fromRect(
          rect: windowRect,
          child: Offstage(
            offstage: entry.minimized,
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
                        height:
                            max(entry.minSize.height, windowRect.size.height),
                        child: Column(
                          children: [
                            Visibility(
                              visible: entry.usesToolbar && !mobileWindow,
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
                        max(entry.minSize.width, windowRect.width),
                        max(entry.minSize.height, windowRect.height),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Rect getRect(WindowEntry entry, bool mobileWindow) {
    final hierarchy = context.read<WindowHierarchyState>();
    final wmRect = hierarchy.wmRect;

    if (entry.maximized || mobileWindow) {
      return Rect.fromLTWH(
        0,
        0,
        wmRect.width,
        wmRect.height,
      );
    }

    switch (entry.windowDock) {
      case WindowDock.TOP_LEFT:
        return Rect.fromLTWH(
          0,
          0,
          wmRect.width / 2,
          wmRect.height / 2,
        );
      case WindowDock.TOP:
        return Rect.fromLTWH(
          0,
          0,
          wmRect.width,
          wmRect.height / 2,
        );
      case WindowDock.TOP_RIGHT:
        return Rect.fromLTWH(
          wmRect.width / 2,
          0,
          wmRect.width / 2,
          wmRect.height / 2,
        );
      case WindowDock.LEFT:
        return Rect.fromLTWH(
          0,
          0,
          wmRect.width / 2,
          wmRect.height,
        );
      case WindowDock.RIGHT:
        return Rect.fromLTWH(
          wmRect.width / 2,
          0,
          wmRect.width / 2,
          wmRect.height,
        );
      case WindowDock.BOTTOM_LEFT:
        return Rect.fromLTWH(
          0,
          wmRect.height / 2,
          wmRect.width / 2,
          wmRect.height / 2,
        );
      case WindowDock.BOTTOM:
        return Rect.fromLTWH(
          0,
          wmRect.height / 2,
          wmRect.width,
          wmRect.height / 2,
        );
      case WindowDock.BOTTOM_RIGHT:
        return Rect.fromLTWH(
          wmRect.width / 2,
          wmRect.height / 2,
          wmRect.width / 2,
          wmRect.height / 2,
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
  }
}
