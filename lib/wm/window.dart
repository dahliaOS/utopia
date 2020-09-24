import 'package:flutter/material.dart';
import 'package:flutter_de/wm/window_entry.dart';
import 'package:flutter_de/wm/window_hierarchy.dart';

class Window extends StatefulWidget {
  final WindowEntry entry;
  final Size initialSize;

  Window({
    Key key,
    @required this.entry,
    this.initialSize = const Size(100, 200),
  });

  _WindowState createState() => _WindowState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      entry.toString();
}

class _WindowState extends State<Window> {
  Offset position = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: SizedBox.fromSize(
        size: widget.initialSize,
        child: GestureDetector(
          onPanStart: (details) =>
              WindowHierarchy.of(context).requestWindowFocus(widget.entry),
          onPanUpdate: (details) {
            position = position.translate(details.delta.dx, details.delta.dy);
            print(details.delta);
            setState(() {});
          },
          onTap: () =>
              WindowHierarchy.of(context).requestWindowFocus(widget.entry),
          child: Material(
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            elevation: 10,
            color: Colors.transparent,
            child: widget.entry.content,
          ),
        ),
      ),
    );
  }
}
