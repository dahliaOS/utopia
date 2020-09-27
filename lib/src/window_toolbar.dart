import 'package:flutter/material.dart';
import 'package:wm/src/window_entry.dart';

abstract class WindowToolbar {
  Widget builder(
    BuildContext context, {
    VoidCallback onClose,
    GestureDragUpdateCallback onDrag,
    WindowEntry entry,
    VoidCallback onDoubleTap,
  });
}

class DefaultWindowToolbar extends WindowToolbar {
  List<WindowToolbarButton> extraButtons;

  DefaultWindowToolbar();

  @override
  Widget builder(
    BuildContext context, {
    VoidCallback onClose,
    GestureDragUpdateCallback onDrag,
    WindowEntry entry,
    VoidCallback onDoubleTap,
  }) {
    final fgColor = entry.toolbarColor.computeLuminance() > 0.5
        ? Colors.grey[900]
        : Colors.white;

    return GestureDetector(
      onPanUpdate: onDrag,
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
                    ...extraButtons,
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
                  right: 32.0 + (32 * extraButtons.length),
                  bottom: 0,
                  child: GestureDetector(
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