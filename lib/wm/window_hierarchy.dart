import 'package:flutter/material.dart';
import 'package:flutter_de/wm/window.dart';
import 'package:flutter_de/wm/window_entry.dart';

class WindowHierarchy extends StatefulWidget {
  WindowHierarchy({
    @required GlobalKey<WindowHierarchyState> key,
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
  final Map<WindowEntry, Window> _windows = {};

  void pushWindowEntry(WindowEntry entry) {
    _windows.addAll({entry: buildWindow(entry)});
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {}),
    );
  }

  void popWindowEntry(WindowEntry entry) {
    _windows.remove(entry);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {}),
    );
  }

  void requestWindowFocus(WindowEntry entry) {
    Window window = _windows[entry];
    _windows.remove(entry);
    _windows.addAll({entry: window});

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return _WindowHierarchyInherithedWidget(
      state: this,
      child: Stack(
        key: ValueKey(_windows),
        children: List.generate(_windows.length, (index) {
          final windows = _windows.values.toList();
          return windows[index];
        }),
      ),
    );
  }

  Window buildWindow(WindowEntry entry) {
    return Window(
      key: ValueKey(entry.id),
      entry: entry,
    );
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
