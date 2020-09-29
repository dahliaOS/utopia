import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_hierarchy.dart';
import 'package:wm/taskbar_item.dart';

class TaskBar extends StatelessWidget {
  final Widget leading;
  final Widget trailing;
  final TaskbarAlignment alignment;
  final Color backgroundColor;
  final Color itemColor;

  TaskBar({
    this.leading,
    this.alignment = TaskbarAlignment.LEFT,
    this.trailing,
    this.backgroundColor = Colors.black,
    this.itemColor = Colors.white,
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
            color: backgroundColor,
            child: Row(
              children: [
                leading ?? Container(),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: taskbarAlignment,
                      children: Provider.of<WindowHierarchyState>(context)
                          .windows
                          .map<Widget>(
                            (e) => TaskBarItem(
                              entry: e,
                              color: itemColor,
                            ),
                          )
                          .toList()
                          .joinType(
                            SizedBox(
                              width: 2,
                            ),
                          ),
                    ),
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
      /*case TaskbarAlignment.CENTER:
        return MainAxisAlignment.center;*/
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
  //CENTER,
  RIGHT,
}

extension JoinList<T> on List<T> {
  List<T> joinType(T separator) {
    List<T> workList = [];

    for (int i = 0; i < (length * 2) - 1; i++) {
      if (i % 2 == 0) {
        workList.add(this[i ~/ 2]);
      } else {
        workList.add(separator);
      }
    }

    return workList;
  }
}
