import 'package:flutter/foundation.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/base.dart';

class WindowCloseButtonPressEvent extends WindowEvent {
  const WindowCloseButtonPressEvent(DateTime timestamp) : super(timestamp);
}

class WindowMaximizeButtonPressEvent extends WindowEvent {
  const WindowMaximizeButtonPressEvent(DateTime timestamp) : super(timestamp);
}

class WindowMinimizeButtonPressEvent extends WindowEvent {
  const WindowMinimizeButtonPressEvent(DateTime timestamp) : super(timestamp);
}

mixin ToolbarEvents on WindowEventHandler {
  @override
  void onEvent(WindowEvent event) {
    if (event is WindowCloseButtonPressEvent) {
      return onCloseButtonPress();
    } else if (event is WindowMaximizeButtonPressEvent) {
      return onMaximizeButtonPress();
    } else if (event is WindowMinimizeButtonPressEvent) {
      return onMinimizeButtonPress();
    }
    super.onEvent(event);
  }

  @protected
  void onCloseButtonPress() {}

  @protected
  void onMaximizeButtonPress() {}

  @protected
  void onMinimizeButtonPress() {}
}
