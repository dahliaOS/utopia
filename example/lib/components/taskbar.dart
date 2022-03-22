import 'dart:async';

import 'package:example/shell.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm.dart';

class Taskbar extends StatefulWidget {
  final WindowHierarchyController controller;

  const Taskbar({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<Taskbar> createState() => _TaskbarState();
}

class _TaskbarState extends State<Taskbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                final provider =
                    Provider.of<ShellDirectorState>(context, listen: false);
                provider.showLauncher = !provider.showLauncher;
              },
              child: SizedBox.fromSize(
                size: const Size.square(24),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
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
                properties: e.registry,
                layout: e.layoutState,
                controller: widget.controller,
              ),
            ),
            const Spacer(),
            const _DateWidget(),
          ],
        ),
      ),
    );
  }
}

class _EntryButton extends StatefulWidget {
  final WindowHierarchyController controller;
  final WindowPropertyRegistry properties;
  final LayoutState layout;

  const _EntryButton({
    required this.properties,
    required this.layout,
    required this.controller,
  });

  @override
  State<_EntryButton> createState() => _EntryButtonState();
}

class _EntryButtonState extends State<_EntryButton> {
  @override
  void initState() {
    super.initState();
    widget.properties.addListener(() => setState(() {}));
    widget.layout.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused =
        widget.controller.isFocused(widget.properties.info.id) &&
            !widget.layout.minimized;

    return Material(
      color: isFocused ? Colors.white : Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.layout.minimized = false;
          widget.controller.requestEntryFocus(widget.properties.info.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: double.infinity,
          alignment: Alignment.center,
          child: Row(
            children: [
              Text(
                widget.properties.info.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: isFocused ? Colors.black : Colors.white,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (widget.layout.alwaysOnTop) const SizedBox(width: 8),
              if (widget.layout.alwaysOnTop)
                Icon(
                  Icons.push_pin,
                  color: isFocused ? Colors.black : Colors.white,
                  size: 12,
                ),
            ],
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
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        DateFormat('EEE dd MMM HH:mm').format(date).toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
    );
  }
}
