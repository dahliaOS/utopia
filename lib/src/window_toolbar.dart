import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_entry.dart';
import 'package:wm/wm.dart';

class DefaultWindowToolbar extends StatefulWidget {
  @override
  _DefaultWindowToolbarState createState() => _DefaultWindowToolbarState();
}

class _DefaultWindowToolbarState extends State<DefaultWindowToolbar> {
  DragUpdateDetails _lastDetails;

  @override
  Widget build(BuildContext context) {
    final entry = context.watch<WindowEntry>();
    final fgColor = entry.toolbarColor.computeLuminance() > 0.5
        ? Colors.grey[900]
        : Colors.white;

    return GestureDetector(
      child: SizedBox(
        height: 32,
        child: Material(
          color: entry.toolbarColor,
          child: IconTheme.merge(
            data: IconThemeData(
              color: fgColor,
              size: 20,
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    SizedBox(width: 8),
                    entry.icon != null
                        ? Image(
                            image: entry.icon ?? ImageProvider,
                            width: 20,
                            height: 20,
                          )
                        : Container(),
                    SizedBox(width: 8),
                    Text(
                      entry.title ?? "",
                      style: TextStyle(
                        color: fgColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    WindowToolbarButton(
                      icon: Icons.minimize,
                      onTap: () {
                        final hierarchy = context.read<WindowHierarchyState>();
                        final windows = hierarchy.entriesByFocus;

                        entry.minimized = true;
                        if (windows.length > 1) {
                          hierarchy
                              .requestWindowFocus(windows[windows.length - 2]);
                        }
                      },
                    ),
                    WindowToolbarButton(
                      icon: entry.maximized
                          ? Icons.unfold_less
                          : Icons.unfold_more,
                      onTap: () {
                        context
                            .read<WindowHierarchyState>()
                            .requestWindowFocus(entry);
                        entry.toggleMaximize();
                        if (!entry.maximized) {
                          entry.windowDock = WindowDock.NORMAL;
                        }
                      },
                    ),
                    WindowToolbarButton(
                      icon: Icons.close,
                      onTap: onClose,
                      hoverColor: Colors.red,
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 32.0 * 3,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: onTap,
                    onDoubleTap: onDoubleTap,
                    onPanUpdate: onDrag,
                    onPanEnd: onDragEnd,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onClose() {
    final entry = context.read<WindowEntry>();
    final hierarchy = context.read<WindowHierarchyState>();
    hierarchy.popWindowEntry(entry);
  }

  void onDrag(details) {
    _lastDetails = details;
    final entry = context.read<WindowEntry>();
    final hierarchy = context.read<WindowHierarchyState>();
    final docked = entry.maximized || entry.windowDock != WindowDock.NORMAL;
    double dockedToolbarOffset;

    switch (entry.windowDock) {
      case WindowDock.TOP:
      case WindowDock.TOP_LEFT:
      case WindowDock.TOP_RIGHT:
      case WindowDock.LEFT:
      case WindowDock.RIGHT:
        dockedToolbarOffset = 0;
        break;
      case WindowDock.BOTTOM:
      case WindowDock.BOTTOM_LEFT:
      case WindowDock.BOTTOM_RIGHT:
        dockedToolbarOffset =
            hierarchy.wmRect.top + hierarchy.wmRect.height / 2;
        break;
      case WindowDock.NORMAL:
      default:
        dockedToolbarOffset = 0;
        break;
    }

    Rect base = Rect.fromLTWH(
      docked
          ? details.globalPosition.dx - entry.windowRect.width / 2
          : entry.windowRect.left,
      docked ? dockedToolbarOffset : entry.windowRect.top,
      entry.windowRect.width,
      entry.windowRect.height,
    );
    hierarchy.requestWindowFocus(entry);
    entry.maximized = false;
    entry.windowDock = WindowDock.NORMAL;

    entry.windowRect = base.translate(
      details.delta.dx,
      details.delta.dy,
    );
    setState(() {});
  }

  void onDragEnd(details) {
    final entry = context.read<WindowEntry>();
    final rect = context.read<WindowHierarchyState>().wmRect;
    final topEdge = _lastDetails.globalPosition.dy <= rect.top + 2;
    final leftEdge = _lastDetails.globalPosition.dx <= rect.left + 2;
    final rightEdge = _lastDetails.globalPosition.dx >= rect.right - 2;

    if (topEdge && _lastDetails.globalPosition.dx <= rect.left + 2 ||
        _lastDetails.globalPosition.dy <= rect.top + 50 && leftEdge) {
      entry.windowDock = WindowDock.TOP_LEFT;
      return;
    }

    if (topEdge && _lastDetails.globalPosition.dx >= rect.bottom - 50 ||
        _lastDetails.globalPosition.dy <= rect.top + 50 && rightEdge) {
      entry.windowDock = WindowDock.TOP_RIGHT;
      return;
    }

    if (topEdge) {
      entry.maximized = true;
      return;
    }

    if (leftEdge) {
      entry.windowDock = WindowDock.LEFT;
      return;
    }

    if (rightEdge) {
      entry.windowDock = WindowDock.RIGHT;
      return;
    }
  }

  void onTap() {
    final entry = context.read<WindowEntry>();
    context.read<WindowHierarchyState>().requestWindowFocus(entry);
  }

  void onDoubleTap() {
    final entry = context.read<WindowEntry>();
    final hierarchy = context.read<WindowHierarchyState>();
    hierarchy.requestWindowFocus(entry);
    entry.toggleMaximize();
  }
}

class WindowToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color hoverColor;

  WindowToolbarButton({
    @required this.icon,
    @required this.onTap,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(32),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: hoverColor,
          onTap: onTap,
          child: Icon(
            icon,
          ),
        ),
      ),
    );
  }
}
