import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm.dart';

import 'overlay_builder.dart';

class TaskbarItem extends StatefulWidget {
  final WindowEntry entry;
  final Color color;

  TaskbarItem({
    Key? key,
    required this.entry,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  _TaskbarItemState createState() => _TaskbarItemState();
}

class _TaskbarItemState extends State<TaskbarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _anim;
  bool _hovering = false;
  bool _showOverlay = false;
  Timer? _overlayTimer;

  GlobalKey _globalKey = GlobalKey();

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
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.entry,
      builder: (context, _) {
        final entry = context.watch<WindowEntry>();
        final hierarchy = context.watch<WindowHierarchyState>();
        final windows = hierarchy.entriesByFocus;

        bool focused = windows.length > 1 ? windows.last.id == entry.id : true;
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
                child: OverlayBuilder(
                  showOverlay: _showOverlay,
                  overlayBuilder: (_) {
                    RenderBox _box = _globalKey.currentContext!
                        .findRenderObject() as RenderBox;

                    final buttonRect = _box.localToGlobal(Offset.zero);

                    final left = max(
                      0.0,
                      min(
                        MediaQuery.of(context).size.width - 200,
                        buttonRect.dx - 100 + (constraints.maxHeight / 2),
                      ),
                    );
                    final right = max(
                      0.0,
                      MediaQuery.of(context).size.width - 200 - left,
                    );

                    return Positioned(
                      left: left,
                      right: right,
                      bottom: hierarchy.insets.bottom,
                      child: ClipRect(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 200,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 24,
                              sigmaY: 24,
                            ),
                            child: Material(
                              color: Colors.white.withOpacity(0.5),
                              child: InkWell(
                                onHover: (value) =>
                                    setState(() => _showOverlay = value),
                                onTap: () => _onTap(context),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 32,
                                      child: Row(
                                        children: [
                                          SizedBox(width: 8),
                                          entry.icon != null
                                              ? Image(
                                                  image: entry.icon!,
                                                  width: 16,
                                                  height: 16,
                                                )
                                              : Icon(
                                                  Icons.apps,
                                                  size: 16,
                                                  color: widget.color,
                                                ),
                                          SizedBox(width: 4),
                                          Text(entry.title ?? ""),
                                          Spacer(),
                                          SizedBox.fromSize(
                                            size: Size.square(32),
                                            child: InkWell(
                                              onTap: () {
                                                _showOverlay = false;
                                                setState(() {});
                                                hierarchy.popWindowEntry(entry);
                                              },
                                              child: Icon(Icons.close),
                                              hoverColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IgnorePointer(
                                      child: Card(
                                        color: Colors.transparent,
                                        clipBehavior: Clip.antiAlias,
                                        margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                                        child: FutureBuilder<Uint8List>(
                                          future: entry.getScreenshot(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Container();
                                            } else {
                                              return Image.memory(
                                                snapshot.data!,
                                              );
                                            }
                                          },
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
                    );
                  },
                  child: GestureDetector(
                    key: _globalKey,
                    onSecondaryTap: () => openDockMenu(context),
                    child: InkWell(
                      onTap: () => _onTap(context),
                      onHover: (value) {
                        if (value) {
                          _overlayTimer = Timer(
                            Duration(milliseconds: 700),
                            () => setState(() => _showOverlay = true),
                          );
                        } else {
                          _overlayTimer?.cancel();
                          _overlayTimer = null;
                          _showOverlay = false;
                        }
                        _hovering = value;
                        setState(() {});
                      },
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
                              entry.icon != null
                                  ? Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Image(
                                        image: entry.icon!,
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.apps,
                                        size: constraints.maxHeight - 8,
                                        color: widget.color,
                                      ),
                                    ),
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 150),
                                curve: Curves.ease,
                                bottom: 0,
                                left: showSelected || _hovering
                                    ? 0
                                    : constraints.maxHeight / 2 - 8,
                                right: showSelected || _hovering
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

  void _onTap(BuildContext context) {
    final entry = context.read<WindowEntry>();
    final hierarchy = context.read<WindowHierarchyState>();
    final windows = hierarchy.entriesByFocus;

    bool focused = windows.last.id == entry.id;

    _overlayTimer?.cancel();
    _overlayTimer = null;
    _showOverlay = false;
    setState(() {});
    if (focused && !entry.minimized) {
      entry.minimized = true;
      if (windows.length > 1) {
        hierarchy.requestWindowFocus(
          windows[windows.length - 2],
        );
      }
    } else {
      entry.minimized = false;
      hierarchy.requestWindowFocus(entry);
    }
  }

  void openDockMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;
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
