import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window.dart';
import 'package:wm/src/window_entry.dart';

class WindowHierarchy extends StatefulWidget {
  final Widget rootWindow;
  final List<Widget> alwaysOnTopWindows;
  final EdgeInsets margin;

  WindowHierarchy({
    GlobalKey<WindowHierarchyState> key,
    this.rootWindow,
    this.alwaysOnTopWindows,
    this.margin,
  }) : super(key: key);

  @override
  WindowHierarchyState createState() => WindowHierarchyState();
}

class WindowHierarchyState extends State<WindowHierarchy> {
  final List<WindowEntry> _entries = [];
  final List<WindowEntryId> _focusTree = [];
  final Map<WindowEntryId, GlobalKey> _windowKeys = {};

  Rect wmRect;

  void pushWindowEntry(WindowEntry entry) {
    _entries.add(entry);
    _focusTree.add(entry.id);
    _windowKeys[entry.id] = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {}),
    );
  }

  void popWindowEntry(WindowEntry entry) {
    _entries.removeWhere((e) => e.id == entry.id);
    _focusTree.remove(entry.id);
    _windowKeys.remove(entry.id);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {}),
    );
  }

  void requestWindowFocus(WindowEntry entry) {
    _focusTree.remove(entry.id);
    _focusTree.add(entry.id);

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  List<WindowEntry> get windows => _entries;

  @override
  Widget build(BuildContext context) {
    wmRect = RelativeRect.fromLTRB(
      widget.margin.left,
      widget.margin.top,
      widget.margin.right,
      widget.margin.bottom,
    ).toRect(Offset.zero & MediaQuery.of(context).size);

    final alwaysOnTopWindows = widget.alwaysOnTopWindows ?? [];

    return Provider<WindowHierarchyState>.value(
      value: this,
      updateShouldNotify: (previous, current) =>
          listEquals(previous._entries, current._entries) ||
          listEquals(previous._focusTree, current._focusTree),
      builder: (context, _) {
        return GestureDetector(
          onTapDown: (details) {},
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              widget.rootWindow ?? Container(),
              Container(
                margin: widget.margin ?? EdgeInsets.zero,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: entriesByFocus
                      .map(
                        (e) => Window(
                          entry: e,
                          key: _windowKeys[e.id],
                        ),
                      )
                      .toList(),
                ),
              ),
              ...alwaysOnTopWindows,
            ],
          ),
        );
      },
    );
  }

  List<WindowEntry> get entriesByFocus {
    List<WindowEntry> workList = [];

    for (WindowEntryId id in _focusTree) {
      workList.add(_entries.firstWhere((element) => element.id == id));
    }

    return workList;
  }
}