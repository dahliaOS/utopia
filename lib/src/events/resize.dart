import 'package:flutter/foundation.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/base.dart';

class WindowResizeStartEvent extends WindowEvent {
  const WindowResizeStartEvent({
    required DateTime timestamp,
  }) : super(timestamp);
}

class WindowResizeEndEvent extends WindowEvent {
  const WindowResizeEndEvent({
    required DateTime timestamp,
  }) : super(timestamp);
}

mixin ResizeEvents on WindowEventHandler {
  @override
  void onEvent(WindowEvent event) {
    if (event is WindowResizeStartEvent) {
      return onStartResize();
    } else if (event is WindowResizeEndEvent) {
      return onEndResize();
    }
    super.onEvent(event);
  }

  @protected
  void onStartResize() {}

  @protected
  void onEndResize() {}
}
