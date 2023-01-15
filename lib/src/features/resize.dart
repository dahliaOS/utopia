import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/resize.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/layout.dart';
import 'package:utopia_wm/src/registry.dart';

/// A [WindowFeature] that adds an invisible frame around the window to resize it.
///
/// It allows horizontal, vertical and diagonal resize. Keep in mind this feature
/// will pad the contents of the window by 8 px in every direction, making it lose some room.
///
/// It supports a min and max size that will stop resizing if reached and also a way
/// to dynamically disable the resizing functionality.
class ResizeWindowFeature extends WindowFeature {
  /// Registry key that holds the minimum size the window is allowed to be resized to.
  /// Defaults to [Size.zero].
  static const WindowPropertyKey<Size> minSize =
      WindowPropertyKey<Size>('feature.resize.minSize', Size.zero);

  /// Registry key that holds the maximum size the window is allowed to be resized to.
  /// Defaults to [Size.infinite].
  static const WindowPropertyKey<Size> maxSize =
      WindowPropertyKey<Size>('feature.resize.maxSize', Size.infinite);

  /// Registry key to toggle dynamically the resize frame in order to enable or disabling resizing.
  /// Defaults to `true`.
  static const WindowPropertyKey<bool> allowResize =
      WindowPropertyKey<bool>('feature.resize.allowResize', true);

  const ResizeWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);
    final LayoutState layout = LayoutState.of(context);
    final WindowEventHandler? eventHandler =
        WindowEventHandler.maybeOf(context);

    return WindowResizeGestureDetector(
      borderThickness: 8,
      listeners: properties.resize.allowResize &&
              layout.dock == WindowDock.none &&
              !layout.fullscreen
          ? _getListeners(context)
          : null,
      onStartResize: () => eventHandler?.onEvent(
        WindowResizeStartEvent(timestamp: DateTime.now()),
      ),
      onEndResize: () => eventHandler?.onEvent(
        WindowResizeEndEvent(timestamp: DateTime.now()),
      ),
      child: content,
    );
  }

  Map<Alignment, GestureDragUpdateCallback> _getListeners(
    BuildContext context,
  ) {
    return {
      Alignment.topLeft: (details) =>
          _onPanUpdate(context, details, top: true, left: true),
      Alignment.topCenter: (details) =>
          _onPanUpdate(context, details, top: true),
      Alignment.topRight: (details) =>
          _onPanUpdate(context, details, top: true, right: true),
      Alignment.centerLeft: (details) =>
          _onPanUpdate(context, details, left: true),
      Alignment.centerRight: (details) =>
          _onPanUpdate(context, details, right: true),
      Alignment.bottomLeft: (details) =>
          _onPanUpdate(context, details, bottom: true, left: true),
      Alignment.bottomCenter: (details) =>
          _onPanUpdate(context, details, bottom: true),
      Alignment.bottomRight: (details) =>
          _onPanUpdate(context, details, bottom: true, right: true),
    };
  }

  void _onPanUpdate(
    BuildContext context,
    DragUpdateDetails details, {
    bool left = false,
    bool top = false,
    bool right = false,
    bool bottom = false,
  }) {
    double getValue(bool apply, Axis axis, double elseValue) {
      final double d = axis == Axis.horizontal
          ? details.globalPosition.dx
          : details.globalPosition.dy;
      return apply ? d : elseValue;
    }

    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context, listen: false);
    final LayoutState layout = LayoutState.of(context, listen: false);

    double newLeft = getValue(
      left,
      Axis.horizontal,
      layout.rect.left,
    );
    double newTop = getValue(
      top,
      Axis.vertical,
      layout.rect.top,
    );
    double newRight = getValue(
      right,
      Axis.horizontal,
      layout.rect.right,
    );
    double newBottom = getValue(
      bottom,
      Axis.vertical,
      layout.rect.bottom,
    );

    final double width = newRight - newLeft;
    final double height = newBottom - newTop;

    if (left) {
      if (width < properties.resize.minSize.width) {
        newLeft = newRight - properties.resize.minSize.width;
      } else if (width > properties.resize.maxSize.width) {
        newLeft = newRight - properties.resize.maxSize.width;
      }
    }

    if (top) {
      if (height < properties.resize.minSize.height) {
        newTop = newBottom - properties.resize.minSize.height;
      } else if (height > properties.resize.maxSize.height) {
        newTop = newBottom - properties.resize.maxSize.height;
      }
    }

    if (right) {
      if (width < properties.resize.minSize.width) {
        newRight = newLeft + properties.resize.minSize.width;
      } else if (width > properties.resize.maxSize.width) {
        newRight = newLeft + properties.resize.maxSize.width;
      }
    }

    if (bottom) {
      if (height < properties.resize.minSize.height) {
        newBottom = newTop + properties.resize.minSize.height;
      } else if (height > properties.resize.maxSize.height) {
        newBottom = newTop + properties.resize.maxSize.height;
      }
    }

    layout.rect = Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }
}

/// The widget that builds the resizing frame for the [ResizeWindowFeature].
/// It should not be used directly and is dedicated to internal library usage.
class WindowResizeGestureDetector extends StatelessWidget {
  final double borderThickness;
  final Map<Alignment, GestureDragUpdateCallback>? listeners;
  final Widget child;
  final VoidCallback? onStartResize;
  final VoidCallback? onEndResize;

  const WindowResizeGestureDetector({
    required this.child,
    required this.borderThickness,
    this.listeners,
    this.onStartResize,
    this.onEndResize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          left: listeners != null ? borderThickness : 0,
          right: listeners != null ? borderThickness : 0,
          top: listeners != null ? borderThickness : 0,
          bottom: listeners != null ? borderThickness : 0,
          child: child,
        ),
        if (listeners != null) Positioned.fill(child: buildFrame(context)),
      ],
    );
  }

  Widget buildFrame(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners![Alignment.topLeft],
              SystemMouseCursors.resizeUpLeft,
            ),
            Expanded(
              child: buildGestureDetector(
                null,
                borderThickness,
                listeners![Alignment.topCenter],
                SystemMouseCursors.resizeUp,
              ),
            ),
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners![Alignment.topRight],
              SystemMouseCursors.resizeUpRight,
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              buildGestureDetector(
                borderThickness,
                null,
                listeners![Alignment.centerLeft],
                SystemMouseCursors.resizeLeft,
              ),
              const Spacer(),
              buildGestureDetector(
                borderThickness,
                null,
                listeners![Alignment.centerRight],
                SystemMouseCursors.resizeRight,
              ),
            ],
          ),
        ),
        Row(
          children: [
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners![Alignment.bottomLeft],
              SystemMouseCursors.resizeDownLeft,
            ),
            Expanded(
              child: buildGestureDetector(
                null,
                borderThickness,
                listeners![Alignment.bottomCenter],
                SystemMouseCursors.resizeDown,
              ),
            ),
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners![Alignment.bottomRight],
              SystemMouseCursors.resizeDownRight,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildGestureDetector(
    double? width,
    double? height,
    GestureDragUpdateCallback? onPanUpdate,
    SystemMouseCursor cursor,
  ) {
    return MouseRegion(
      cursor: cursor,
      child: SizedBox(
        width: width,
        height: height,
        child: GestureDetector(
          onPanStart: onStartResize != null ? (_) => onStartResize!() : null,
          onPanUpdate: onPanUpdate,
          onPanEnd: onEndResize != null ? (_) => onEndResize!() : null,
        ),
      ),
    );
  }
}
