import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window_entry.dart';
import 'package:wm/src/window_hierarchy.dart';

class TaskbarItem extends StatefulWidget {
  final WindowEntry entry;
  final Color color;

  TaskbarItem({
    @required this.entry,
    this.color,
  });

  @override
  _TaskbarItemState createState() => _TaskbarItemState();
}

class _TaskbarItemState extends State<TaskbarItem>
    with SingleTickerProviderStateMixin {
  AnimationController _ac;
  Animation<double> _anim;
  bool hovering = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _anim = CurvedAnimation(
      parent: _ac,
      curve: Curves.ease,
      reverseCurve: Curves.ease,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _ac.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.entry,
      builder: (context, _) {
        final entry = context.watch<WindowEntry>();
        final windows =
            Provider.of<WindowHierarchyState>(context).entriesByFocus;

        bool focused = windows.last.id == entry.id;
        bool showSelected = focused && !entry.minimized;

        if (showSelected) {
          _ac.animateTo(1);
        } else {
          _ac.animateBack(0);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox.fromSize(
              size: Size.square(constraints.maxHeight),
              child: Material(
                type: MaterialType.transparency,
                child: Tooltip(
                  message: entry.title,
                  child: GestureDetector(
                    onSecondaryTap: () => openDockMenu(context),
                    child: InkWell(
                      onTap: () {
                        if (focused && !entry.minimized) {
                          entry.minimized = true;
                          if (windows.length > 1) {
                            Provider.of<WindowHierarchyState>(context,
                                    listen: false)
                                .requestWindowFocus(
                                    windows[windows.length - 2]);
                          }
                        } else {
                          entry.minimized = false;
                          Provider.of<WindowHierarchyState>(context,
                                  listen: false)
                              .requestWindowFocus(entry);
                        }
                      },
                      onHover: (value) => setState(() => hovering = value),
                      hoverColor: widget.color.withOpacity(0.1),
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              FadeTransition(
                                opacity: _anim,
                                child: SizeTransition(
                                  sizeFactor: _anim,
                                  axis: Axis.vertical,
                                  axisAlignment: 1,
                                  child: Container(
                                    color: widget.color.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Image(
                                  image: entry.icon,
                                ),
                              ),
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 150),
                                curve: Curves.ease,
                                bottom: 0,
                                left: showSelected || hovering
                                    ? 0
                                    : constraints.maxHeight / 2 - 8,
                                right: showSelected || hovering
                                    ? 0
                                    : constraints.maxHeight / 2 - 8,
                                height: 2,
                                child: Material(
                                  color: widget.color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openDockMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.topLeft(Offset.zero),
            ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    var result = await showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: Text("Normal"),
          value: WindowDock.NORMAL,
        ),
        PopupMenuItem(
          child: Text("Top left"),
          value: WindowDock.TOP_LEFT,
        ),
        PopupMenuItem(
          child: Text("Top"),
          value: WindowDock.TOP,
        ),
        PopupMenuItem(
          child: Text("Top right"),
          value: WindowDock.TOP_RIGHT,
        ),
        PopupMenuItem(
          child: Text("Left"),
          value: WindowDock.LEFT,
        ),
        PopupMenuItem(
          child: Text("Right"),
          value: WindowDock.RIGHT,
        ),
        PopupMenuItem(
          child: Text("Bottom left"),
          value: WindowDock.BOTTOM_LEFT,
        ),
        PopupMenuItem(
          child: Text("Bottom"),
          value: WindowDock.BOTTOM,
        ),
        PopupMenuItem(
          child: Text("Bottom right"),
          value: WindowDock.BOTTOM_RIGHT,
        ),
      ],
    );

    if (result != null) {
      widget.entry.windowDock = result;
    }
  }
}
