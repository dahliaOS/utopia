import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_entry.dart';
import 'package:wm/src/window_hierarchy.dart';

class TaskBarItem extends StatelessWidget {
  final WindowEntry entry;

  TaskBarItem({
    @required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    bool focused =
        Provider.of<WindowHierarchyState>(context).entriesByFocus.last.id ==
            entry.id;
    bool showSelected = focused && !entry.minimized;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.fromSize(
          size: Size.square(constraints.maxHeight),
          child: Material(
            type: MaterialType.transparency,
            child: Tooltip(
              message: entry.title,
              child: InkWell(
                onTap: () {
                  if (focused && !entry.minimized) {
                    entry.minimized = true;
                    Provider.of<WindowHierarchyState>(context, listen: false)
                        .requestWindowFocus(entry);
                  } else {
                    entry.minimized = false;
                    Provider.of<WindowHierarchyState>(context, listen: false)
                        .requestWindowFocus(entry);
                  }
                },
                hoverColor: Colors.white.withOpacity(0.2),
                child: Stack(
                  children: [
                    Visibility(
                      visible: showSelected,
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Image(
                        image: entry.icon,
                        width: constraints.maxHeight - 16,
                        height: constraints.maxHeight - 16,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: showSelected ? 0 : 6,
                      right: showSelected ? 0 : 6,
                      height: 3,
                      child: Material(
                        color: entry.toolbarColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
