import 'dart:async';

import 'package:example/example.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utopia_wm/wm_new.dart';

class Toolbar extends StatefulWidget {
  static const entry = WindowEntry(
    features: [
      GeometryWindowFeature(),
      ResizeWindowFeature(),
      FocusableWindowFeature(),
      SurfaceWindowFeature(),
      ToolbarWindowFeature(),
    ],
    properties: {
      WindowEntry.title: "Example window",
      WindowEntry.icon: null,
      GeometryWindowFeature.size: Size(400, 300),
      GeometryWindowFeature.position: Offset.zero,
      ResizeWindowFeature.minSize: Size(200, 200),
      ResizeWindowFeature.maxSize: Size(800, 800),
    },
  );

  final WindowHierarchyController controller;

  const Toolbar({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            height: 24,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      widget.controller.addWindowEntry(
                          Toolbar.entry.newInstance(const ExampleApp()));
                    },
                    child: SizedBox.fromSize(
                      size: const Size.square(24),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const ShapeDecoration(
                            shape: CircleBorder(),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...widget.controller.entries.map(
                    (e) => _EntryButton(
                      properties: e.registry.info,
                      controller: widget.controller,
                    ),
                  ),
                  const Spacer(),
                  const _DateWidget(),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryButton extends StatelessWidget {
  final WindowHierarchyController controller;
  final InfoWindowProperties properties;

  const _EntryButton({
    required this.properties,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFocused = controller.isFocused(properties.id);

    return Material(
      color: isFocused ? Colors.white : Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.requestEntryFocus(properties.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: double.infinity,
          alignment: Alignment.center,
          child: Text(
            properties.title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 1,
              color: isFocused ? Colors.black : Colors.white,
              fontFamily: 'Ubuntu Mono',
              fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateWidget extends StatefulWidget {
  const _DateWidget({Key? key}) : super(key: key);

  @override
  _DateWidgetState createState() => _DateWidgetState();
}

class _DateWidgetState extends State<_DateWidget> {
  late DateTime date;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      date = DateTime.now();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('EEE dd MMM HH:mm').format(date).toUpperCase(),
      style: const TextStyle(
        fontSize: 14,
        letterSpacing: 1,
        color: Colors.white,
        fontFamily: 'Ubuntu Mono',
      ),
    );
  }
}
