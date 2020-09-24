import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_de/wm/window_entry.dart';
import 'package:flutter_de/wm/window_hierarchy.dart';
import 'package:flutter_de/wm/window_resize_gesture_detector.dart';
import 'package:flutter_de/wm/window_toolbar.dart';

class Window extends StatefulWidget {
  final WindowEntry entry;
  final Size initialSize;

  Window({
    Key key,
    @required this.entry,
    this.initialSize = const Size(480, 360),
  });

  _WindowState createState() => _WindowState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      entry.title;
}

class _WindowState extends State<Window> {
  static const double _resizingSpacing = 8;
  Rect _windowState;
  bool _maximized = false;

  @override
  void initState() {
    _windowState = Rect.fromLTWH(
      0,
      0,
      widget.initialSize.width,
      widget.initialSize.height,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    Rect windowRect = _maximized
        ? Rect.fromLTWH(
            0,
            0,
            screenSize.width,
            screenSize.height,
          )
        : _windowState;

    return Positioned(
      left: windowRect.left,
      top: windowRect.top,
      child: WindowEntryInherithedWidget(
        entry: widget.entry,
        child: SizedBox(
          width: max(200, windowRect.size.width),
          height: max(24, windowRect.size.height),
          child: Stack(
            children: [
              GestureDetector(
                onPanStart: (details) => WindowHierarchy.of(context)
                    .requestWindowFocus(widget.entry),
                onTapDown: (details) => WindowHierarchy.of(context)
                    .requestWindowFocus(widget.entry),
                child: Material(
                  borderRadius: BorderRadius.circular(_maximized ? 0 : 4),
                  clipBehavior: Clip.antiAlias,
                  elevation: _maximized ? 0 : 2,
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      height: max(36, windowRect.size.height),
                      child: Column(
                        children: [
                          WindowToolbar(
                            onPanUpdate: (details) {
                              if (_maximized) return;

                              _windowState = Rect.fromLTWH(
                                _windowState.left + details.delta.dx,
                                _windowState.top + details.delta.dy,
                                _windowState.width,
                                _windowState.height,
                              );
                              setState(() {});
                            },
                            extraButtons: [
                              WindowToolbarButton(
                                icon: _maximized
                                    ? Icons.unfold_less
                                    : Icons.unfold_more,
                                onTap: () => setState(
                                  () => _maximized = !_maximized,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: widget.entry.content,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !_maximized,
                child: WindowResizeGestureDetector(
                  borderThickness: _resizingSpacing,
                  listeners: _listeners,
                ),
              ),
            ],
          ),
        ),
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
    double _delta(bool apply, Axis axis) {
      double d = axis == Axis.horizontal ? details.delta.dx : details.delta.dy;
      return apply ? d : 0;
    }

    _windowState = Rect.fromLTRB(
      _windowState.left + _delta(left, Axis.horizontal),
      _windowState.top + _delta(top, Axis.vertical),
      _windowState.right + _delta(right, Axis.horizontal),
      _windowState.bottom + _delta(bottom, Axis.vertical),
    );

    setState(() {});
  }
}
