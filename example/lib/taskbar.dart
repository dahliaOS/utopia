import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm.dart';

import 'taskbar_item.dart';

class Taskbar extends StatefulWidget {
  final Widget? leading;
  final Widget? trailing;
  final TaskbarAlignment alignment;
  final Color backgroundColor;
  final Color itemColor;

  Taskbar({
    this.leading,
    this.alignment = TaskbarAlignment.LEFT,
    this.trailing,
    this.backgroundColor = Colors.black,
    this.itemColor = Colors.white,
  });

  @override
  _TaskbarState createState() => _TaskbarState();
}

class _TaskbarState extends State<Taskbar> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final appIcons = Align(
      alignment: taskbarAlignment,
      child: SingleChildScrollView(
        reverse: widget.alignment == TaskbarAlignment.RIGHT,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: Provider.of<WindowHierarchyState>(context)
              .windows
              .map<Widget>(
                (e) => TaskbarItem(
                  entry: e,
                  color: widget.itemColor,
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
    );

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
            color: widget.backgroundColor,
            child: Stack(
              children: [
                Row(
                  children: [
                    widget.leading ?? Container(),
                    Expanded(
                      child: widget.alignment != TaskbarAlignment.CENTER
                          ? appIcons
                          : Container(),
                    ),
                    widget.trailing ?? Container(),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 48,
                  child: widget.alignment == TaskbarAlignment.CENTER
                      ? appIcons
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment get taskbarAlignment {
    switch (widget.alignment) {
      case TaskbarAlignment.CENTER:
        return Alignment.center;
      case TaskbarAlignment.RIGHT:
        return Alignment.centerRight;
      case TaskbarAlignment.LEFT:
      default:
        return Alignment.centerLeft;
    }
  }
}

enum TaskbarAlignment {
  LEFT,
  CENTER,
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
