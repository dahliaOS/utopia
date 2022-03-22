import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/base.dart';
import 'package:utopia_wm/src/layout.dart';

mixin LayoutEvents on WindowEventHandler {
  @override
  void onEvent(WindowEvent event) {
    if (event is WindowMinimizeEvent) {
      return onMinimize(event.minimized);
    } else if (event is WindowFullscreenEvent) {
      return onFullscreen(event.fullscreen);
    } else if (event is WindowDockChangeEvent) {
      return onDockChanged(event.dock);
    } else if (event is WindowSizeChangeEvent) {
      return onSizeChanged(event.size);
    } else if (event is WindowPositionChangeEvent) {
      return onPositionChanged(event.position);
    } else if (event is WindowAlwaysOnTopChangeEvent) {
      return onAlwaysOnTopChanged(event.alwaysOnTop);
    } else if (event is WindowAlwaysOnTopModeChangeEvent) {
      return onAlwaysOnTopModeChanged(event.alwaysOnTopMode);
    }
    super.onEvent(event);
  }

  @protected
  void onMinimize(bool minimized) {}

  @protected
  void onFullscreen(bool fullscreen) {}

  @protected
  void onDockChanged(WindowDock dock) {}

  @protected
  void onSizeChanged(Size size) {}

  @protected
  void onPositionChanged(Offset position) {}

  @protected
  void onAlwaysOnTopChanged(bool alwaysOnTop) {}

  @protected
  void onAlwaysOnTopModeChanged(AlwaysOnTopMode alwaysOnTopMode) {}
}

class WindowMinimizeEvent extends WindowEvent {
  final bool minimized;

  const WindowMinimizeEvent({
    required this.minimized,
    required DateTime timestamp,
  }) : super(timestamp);
}

class WindowFullscreenEvent extends WindowEvent {
  final bool fullscreen;

  const WindowFullscreenEvent({
    required this.fullscreen,
    required DateTime timestamp,
  }) : super(timestamp);
}

class WindowDockChangeEvent extends WindowEvent {
  final WindowDock dock;

  const WindowDockChangeEvent({
    required this.dock,
    required DateTime timestamp,
  }) : super(timestamp);
}

class WindowSizeChangeEvent extends WindowEvent {
  final Size size;

  const WindowSizeChangeEvent({
    required this.size,
    required DateTime timestamp,
  }) : super(timestamp);
}

class WindowPositionChangeEvent extends WindowEvent {
  final Offset position;

  const WindowPositionChangeEvent({
    required this.position,
    required DateTime timestamp,
  }) : super(timestamp);
}

class WindowAlwaysOnTopChangeEvent extends WindowEvent {
  final bool alwaysOnTop;

  const WindowAlwaysOnTopChangeEvent({
    required this.alwaysOnTop,
    required DateTime timestamp,
  }) : super(timestamp);
}

class WindowAlwaysOnTopModeChangeEvent extends WindowEvent {
  final AlwaysOnTopMode alwaysOnTopMode;

  const WindowAlwaysOnTopModeChangeEvent({
    required this.alwaysOnTopMode,
    required DateTime timestamp,
  }) : super(timestamp);
}
