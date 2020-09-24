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
  final List<WindowEntry> _windows = [];

  void pushWindowEntry(WindowEntry entry) =>
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() => _windows.add(entry)),
      );

  void requestWindowFocus(WindowEntry entry) {
    print(_windows);
    _windows.remove(entry);
    print(_windows);
    _windows.insert(0, entry);
    print(_windows);

    print("kind poggers");

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return _WindowHierarchyInherithedWidget(
      state: this,
      child: Stack(
        children: List.generate(_windows.length, (index) {
          final WindowEntry entry = _windows[index];

          return Window(
            entry: entry,
          );
        }),
      ),
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
