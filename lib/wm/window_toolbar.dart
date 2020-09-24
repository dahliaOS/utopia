import 'package:flutter/material.dart';
import 'package:flutter_de/wm/window_entry.dart';
import 'package:flutter_de/wm/window_hierarchy.dart';

class WindowToolbar extends StatelessWidget {
  final GestureDragUpdateCallback onPanUpdate;
  final List<WindowToolbarButton> extraButtons;

  WindowToolbar({
    this.onPanUpdate,
    this.extraButtons = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      child: SizedBox(
        height: 24,
        child: Material(
          child: Row(
            children: [
              SizedBox(width: 8),
              Text(WindowEntry.of(context).title),
              Spacer(),
              ...extraButtons,
              WindowToolbarButton(
                icon: Icons.close,
                onTap: () => WindowHierarchy.of(context).popWindowEntry(
                  WindowEntry.of(context),
                ),
                hoverColor: Colors.red,
              ),
            ],
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
      size: Size.square(24),
      child: Material(
        child: InkWell(
          hoverColor: hoverColor,
          onTap: onTap,
          child: Icon(
            icon,
            color: Colors.grey[900],
            size: 16,
          ),
        ),
      ),
    );
  }
}
