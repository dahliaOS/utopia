import 'package:flutter/material.dart';

class WindowEntry {
  final WindowEntryId id;
  String title;
  final Widget content;

  WindowEntry({
    @required this.title,
    @required this.content,
  }) : id = WindowEntryId();

  @override
  String toString() {
    return {
      "title": this.title,
      "content": this.content,
      "hashCode": this.hashCode,
    }.toString();
  }

  static WindowEntry of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WindowEntryInherithedWidget>()
        ?.entry;
  }
}

class WindowEntryId {
  @override
  String toString() => hashCode.toString();
}

class WindowEntryInherithedWidget extends InheritedWidget {
  final Widget child;
  final WindowEntry entry;

  WindowEntryInherithedWidget({
    @required this.entry,
    @required this.child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(WindowEntryInherithedWidget oldWidget) => false;
}
