import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_hierarchy.dart';
import 'package:wm/taskbar_item.dart';

class TaskBar extends StatelessWidget {
  final Widget leading;
  final Widget trailing;
  final TaskbarAlignment alignment;

  TaskBar({
    this.leading,
    this.alignment = TaskbarAlignment.LEFT,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 48,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 24,
            sigmaY: 24,
          ),
          child: Material(
            color: Colors.black.withAlpha(150),
            child: Row(
              children: [
                leading ?? Container(),
                Expanded(
                  child: Row(
                    mainAxisAlignment: taskbarAlignment,
                    children: Provider.of<WindowHierarchyState>(context)
                        .windows
                        .map(
                          (e) => TaskBarItem(entry: e),
                        )
                        .toList(),
                  ),
                ),
                trailing ?? Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MainAxisAlignment get taskbarAlignment {
    switch (alignment) {
      case TaskbarAlignment.CENTER:
        return MainAxisAlignment.center;
      case TaskbarAlignment.RIGHT:
        return MainAxisAlignment.end;
      case TaskbarAlignment.LEFT:
      default:
        return MainAxisAlignment.start;
    }
  }
}

enum TaskbarAlignment {
  LEFT,
  CENTER,
  RIGHT,
}
