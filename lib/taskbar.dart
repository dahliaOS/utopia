import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_hierarchy.dart';
import 'package:wm/taskbar_item.dart';

class TaskBar extends StatefulWidget {
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
  _TaskBarState createState() => _TaskBarState();
}

class _TaskBarState extends State<TaskBar> with SingleTickerProviderStateMixin {
  AnimationController _ac;

  @override
  void initState() {
    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> positionAnim =
        Tween<double>(begin: -34, end: 0).animate(_ac);

    return AnimatedBuilder(
      animation: _ac,
      builder: (context, _) {
        return Stack(
          children: [
            IgnorePointer(
              ignoring: _ac.value <= 0.5,
              child: GestureDetector(
                onTap: () => _ac.fling(velocity: -1),
                child: Container(
                  color: Colors.black.withOpacity(_ac.value * 0.4),
                ),
              ),
            ),
            Positioned(
              bottom: positionAnim.value,
              left: 0,
              right: 0,
              height: 48,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  _ac.value -= details.primaryDelta / (48 - 14);
                },
                onVerticalDragEnd: (details) {
                  if (_ac.value > 0.5) {
                    _ac.fling(velocity: 1);
                  } else {
                    _ac.fling(velocity: -1);
                  }
                },
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
                          IgnorePointer(
                            ignoring: _ac.value <= 0.5,
                            child: Opacity(
                              opacity: _ac.value,
                              child: Row(
                                children: [
                                  widget.leading ?? Container(),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: taskbarAlignment,
                                        children:
                                            Provider.of<WindowHierarchyState>(
                                                    context)
                                                .windows
                                                .map<Widget>(
                                                  (e) => TaskBarItem(
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
                                  ),
                                  widget.trailing ?? Container(),
                                ],
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: 1 - _ac.value,
                            child: Container(
                              height: 14,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: SizedBox(
                                width: 72,
                                height: 4,
                                child: Material(
                                  shape: StadiumBorder(),
                                  color: Colors.grey[900],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  MainAxisAlignment get taskbarAlignment {
    switch (widget.alignment) {
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
