import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_entry.dart';
import 'package:wm/wm.dart';

abstract class WindowToolbar {
  Widget builder(
    BuildContext context, {
    VoidCallback onClose,
    GestureDragUpdateCallback onDrag,
    GestureDragEndCallback onDragEnd,
    WindowEntry entry,
    VoidCallback onTap,
    VoidCallback onDoubleTap,
  });
}

class DefaultWindowToolbar extends StatefulWidget {
  @override
  _DefaultWindowToolbarState createState() => _DefaultWindowToolbarState();
}

class _DefaultWindowToolbarState extends State<DefaultWindowToolbar> {
  DragUpdateDetails lastDetails;

  @override
  Widget build(BuildContext context) {
    final entry = context.watch<WindowEntry>();
    final fgColor = entry.toolbarColor.computeLuminance() > 0.5
        ? Colors.grey[900]
        : Colors.white;

    return GestureDetector(
      onPanUpdate: onDrag,
      onPanEnd: onDragEnd,
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
                    ),
                    Spacer(),
                    WindowToolbarButton(
                      icon: Icons.minimize,
                      onTap: () {
                        entry.minimized = true;
                        setState(() {});
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
    lastDetails = details;
    final entry = context.read<WindowEntry>();
    final hierarchy = context.read<WindowHierarchyState>();
    Rect base = Rect.fromLTWH(
      entry.maximized
          ? details.globalPosition.dx - entry.windowRect.width / 2
          : entry.windowRect.left,
      entry.maximized ? 0 : entry.windowRect.top,
      entry.windowRect.width,
      entry.windowRect.height,
    );
    hierarchy.requestWindowFocus(entry);
    entry.maximized = false;

    entry.windowRect = base.translate(
      details.delta.dx,
      details.delta.dy,
    );
    setState(() {});
  }

  void onDragEnd(details) {
    final entry = context.read<WindowEntry>();
    if (lastDetails.globalPosition.dy <= 2) {
      entry.maximized = true;
      setState(() {});
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

class _DefaultWindowToolbar extends WindowToolbar {
  List<WindowToolbarButton> extraButtons;

  _DefaultWindowToolbar();

  @override
  Widget builder(
    BuildContext context, {
    VoidCallback onClose,
    GestureDragUpdateCallback onDrag,
    GestureDragEndCallback onDragEnd,
    WindowEntry entry,
    VoidCallback onTap,
    VoidCallback onDoubleTap,
  }) {}
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
