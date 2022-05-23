import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/base.dart';
import 'package:utopia_wm/src/layout.dart';

/// Mixin to add shorthands for every layout related event.
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

  /// Handler for [WindowMinimizeEvent] events.
  @protected
  void onMinimize(bool minimized) {}

  /// Handler for [WindowFullscreenEvent] events.
  @protected
  void onFullscreen(bool fullscreen) {}

  /// Handler for [WindowDockChangeEvent] events.
  @protected
  void onDockChanged(WindowDock dock) {}

  /// Handler for [WindowSizeChangeEvent] events.
  @protected
  void onSizeChanged(Size size) {}

  /// Handler for [WindowPositionChangeEvent] events.
  @protected
  void onPositionChanged(Offset position) {}

  /// Handler for [WindowAlwaysOnTopChangeEvent] events.
  @protected
  void onAlwaysOnTopChanged(bool alwaysOnTop) {}

  /// Handler for [WindowAlwaysOnTopModeChangeEvent] events.
  @protected
  void onAlwaysOnTopModeChanged(AlwaysOnTopMode alwaysOnTopMode) {}
}

/// Event generated when the minimized status of the window changes.
class WindowMinimizeEvent extends WindowEvent {
  /// Whether it was requested to be minimized or not.
  final bool minimized;

  const WindowMinimizeEvent({
    required this.minimized,
    required super.timestamp,
  });
}

/// Event generated when the fullscreen status of the window changes.
class WindowFullscreenEvent extends WindowEvent {
  /// Whether it was requested to be fullscreen or not.
  final bool fullscreen;

  const WindowFullscreenEvent({
    required this.fullscreen,
    required super.timestamp,
  });
}

/// Event generated when the docking of the window changes.
class WindowDockChangeEvent extends WindowEvent {
  /// The new dock of the window.
  final WindowDock dock;

  const WindowDockChangeEvent({
    required this.dock,
    required super.timestamp,
  });
}

/// Event generated when the size of the window changes.
class WindowSizeChangeEvent extends WindowEvent {
  /// The new size of the window.
  final Size size;

  const WindowSizeChangeEvent({
    required this.size,
    required super.timestamp,
  });
}

/// Event generated when the position of the window changes.
class WindowPositionChangeEvent extends WindowEvent {
  /// The new position of the window.
  final Offset position;

  const WindowPositionChangeEvent({
    required this.position,
    required super.timestamp,
  });
}

/// Event generated when the always on top status of the window changes.
class WindowAlwaysOnTopChangeEvent extends WindowEvent {
  /// Whether it was requested to be always on top or not.
  final bool alwaysOnTop;

  const WindowAlwaysOnTopChangeEvent({
    required this.alwaysOnTop,
    required super.timestamp,
  });
}

/// Event generated when the always on top mode of the window changes.
class WindowAlwaysOnTopModeChangeEvent extends WindowEvent {
  /// The new always on top mode of the window.
  final AlwaysOnTopMode alwaysOnTopMode;

  const WindowAlwaysOnTopModeChangeEvent({
    required this.alwaysOnTopMode,
    required super.timestamp,
  });
}
