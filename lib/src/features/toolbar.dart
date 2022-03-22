import 'package:flutter/material.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/events.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/hierarchy.dart';
import 'package:utopia_wm/src/layout.dart';
import 'package:utopia_wm/src/registry.dart';

class ToolbarWindowFeature extends WindowFeature {
  static const WindowPropertyKey<double> size =
      WindowPropertyKey('feature.toolbar.size', 24);
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

  @override
  List<WindowPropertyKey> get requiredProperties => [];
}

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
          width: 1,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
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
                  WindowMinimizeButtonPressEvent(DateTime.now()),
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
                  WindowMaximizeButtonPressEvent(DateTime.now()),
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
                  WindowCloseButtonPressEvent(DateTime.now()),
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
