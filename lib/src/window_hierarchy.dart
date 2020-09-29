import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm/src/window.dart';
import 'package:wm/src/window_entry.dart';

class WindowHierarchy extends StatefulWidget {
  final Widget rootWindow;
  final Widget alwaysOnTopWindow;
  final EdgeInsets margin;

  WindowHierarchy({
    GlobalKey<WindowHierarchyState> key,
    this.rootWindow,
    this.alwaysOnTopWindow,
    this.margin,
  }) : super(key: key);

  @override
  WindowHierarchyState createState() => WindowHierarchyState();

  static WindowHierarchyState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_WindowHierarchyInherithedWidget>()
        ?.state;
  }
}

class WindowHierarchyState extends State<WindowHierarchy> {
  final List<WindowEntry> _entries = [];
  final List<WindowEntryId> _focusTree = [];
  final Map<WindowEntryId, GlobalKey> _windowKeys = {};

  BoxConstraints constraints;

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
    constraints = BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width - widget.margin.horizontal,
      maxHeight: MediaQuery.of(context).size.height - widget.margin.vertical,
    );
    
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
              widget.alwaysOnTopWindow ?? Container(),
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

class _WindowHierarchyInherithedWidget extends InheritedWidget {
  final Widget child;
  final WindowHierarchyState state;

  _WindowHierarchyInherithedWidget({
    @required this.state,
    @required this.child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_WindowHierarchyInherithedWidget oldWidget) =>
      this.state != oldWidget.state;
}
