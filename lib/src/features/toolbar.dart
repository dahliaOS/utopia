import 'package:flutter/material.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/events.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/hierarchy.dart';
import 'package:utopia_wm/src/layout.dart';
import 'package:utopia_wm/src/registry.dart';

/// The [WindowFeature] that is responsible of drawing the toolbar where usually the title
/// and buttons of the window live.
///
/// By default allows only vertically stacked toolbars to be used but it's rather simple
/// to make a feature that is capable of adding one in an horizontal layout.
class ToolbarWindowFeature extends WindowFeature {
  /// Registry key that holds the vertical size of the toolbar. Defaults to `24`.
  static const WindowPropertyKey<double> size =
      WindowPropertyKey('feature.toolbar.size', 24);

  /// Registry key that defines the actual widget used to render the toolbar. It is
  /// expected to have the width of the window and height of [ToolbarWindowFeature.size].
  /// Defaults to [DefaultToolbar].
  static const WindowPropertyKey<Widget> widget =
      WindowPropertyKey('feature.toolbar.widget', DefaultToolbar());

  const ToolbarWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);
    final LayoutState layout = LayoutState.of(context);

    if (layout.fullscreen) return content;

    return Column(
      children: [
        SizedBox(
          height: properties.toolbar.size,
          child: properties.toolbar.widget,
        ),
        Expanded(child: content),
      ],
    );
  }
}

/// The default and opinionated implementation of the window toolbar.
/// It follows the white on black design inspired by the default DE of Fuchsia.
///
/// It displays the icon if available, the title and the three buttons to minimize,
/// maximize and close the window.
///
/// This widget is not expected to be used in a proper WM but rather serves as an
/// example of how a toolbar should be implemented.
class DefaultToolbar extends StatelessWidget {
  const DefaultToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);
    final LayoutState layout = LayoutState.of(context);
    final WindowEventHandler? eventHandler =
        WindowEventHandler.maybeOf(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            properties.info.title.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onPanStart: (details) {
                      if (layout.dock != WindowDock.none) {
                        layout.dock = WindowDock.none;
                        layout.position = details.globalPosition +
                            Offset(
                              -layout.size.width / 2,
                              -properties.toolbar.size / 2,
                            );
                      }
                    },
                    onPanUpdate: (details) {
                      layout.position += details.delta;
                    },
                    onDoubleTap: () {
                      if (layout.dock == WindowDock.maximized) {
                        layout.dock = WindowDock.none;
                      } else {
                        layout.dock = WindowDock.maximized;
                      }
                    },
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                layout.minimized = true;
                eventHandler?.onEvent(
                  WindowMinimizeButtonPressEvent(timestamp: DateTime.now()),
                );
              },
              child: SizedBox.fromSize(
                size: Size.square(properties.toolbar.size),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: ShapeDecoration(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (layout.dock == WindowDock.maximized) {
                  layout.dock = WindowDock.none;
                } else {
                  layout.dock = WindowDock.maximized;
                }
                eventHandler?.onEvent(
                  WindowMaximizeButtonPressEvent(timestamp: DateTime.now()),
                );
              },
              child: SizedBox.fromSize(
                size: Size.square(properties.toolbar.size),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                eventHandler?.onEvent(
                  WindowCloseButtonPressEvent(timestamp: DateTime.now()),
                );
                WindowHierarchy.of(context, listen: false)
                    .removeWindowEntry(properties.info.id);
              },
              child: SizedBox.fromSize(
                size: Size.square(properties.toolbar.size),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
