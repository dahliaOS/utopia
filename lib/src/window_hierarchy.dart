import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/dismissible_overlay.dart';
import 'package:utopia_wm/src/dismissible_overlay_entry.dart';
import 'package:utopia_wm/src/window.dart';
import 'package:utopia_wm/src/window_entry.dart';

class WindowHierarchy extends StatefulWidget {
  final Widget? rootWindow;
  final List<Widget>? alwaysOnTopWindows;
  final EdgeInsets margin;

  WindowHierarchy({
    GlobalKey<WindowHierarchyState>? key,
    this.rootWindow,
    this.alwaysOnTopWindows,
    this.margin = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  WindowHierarchyState createState() => WindowHierarchyState();
}

class WindowHierarchyState extends State<WindowHierarchy> {
  final List<WindowEntry> _windowEntries = [];
  final List<WindowEntryId> _focusTree = [];
  final List<DismissibleOverlayEntry> _overlayEntries = [];
  final Map<WindowEntryId, GlobalKey> _windowKeys = {};
  final Map<DismissibleOverlayEntryId, GlobalKey> _overlayKeys = {};

  //bool _showWindowSwitcher = false;

  late RelativeRect insets;
  late Rect wmRect;

  /*@override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_windowSwitcherListener);
  }

  @override
  void dispose() {
    super.dispose();
    RawKeyboard.instance.removeListener(_windowSwitcherListener);
  }*/

  void pushWindowEntry(WindowEntry entry) {
    _windowEntries.add(entry);
    _focusTree.add(entry.id);
    _windowKeys[entry.id] = GlobalKey();
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => setState(() {}),
    );
  }

  void popWindowEntry(WindowEntry entry) {
    _windowEntries.remove(entry);
    _focusTree.remove(entry.id);
    _windowKeys.remove(entry.id);
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => setState(() {}),
    );
  }

  void requestWindowFocus(WindowEntry entry) {
    _focusTree.remove(entry.id);
    _focusTree.add(entry.id);

    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }

  void pushOverlayEntry(DismissibleOverlayEntry entry) {
    if (_overlayEntries.any((e) => e.uniqueId == entry.uniqueId)) return;

    _overlayEntries.add(entry);
    _overlayKeys[entry.id] = GlobalKey();

    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }

  void popOverlayEntry(DismissibleOverlayEntry entry) {
    _overlayEntries.remove(entry);
    _overlayKeys.remove(entry.id);

    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }

  List<WindowEntry> get windows => _windowEntries;

  @override
  Widget build(BuildContext context) {
    insets = RelativeRect.fromLTRB(
      widget.margin.left,
      widget.margin.top,
      widget.margin.right,
      widget.margin.bottom,
    );
    wmRect = insets.toRect(Offset.zero & MediaQuery.of(context).size);

    final alwaysOnTopWindows = widget.alwaysOnTopWindows ?? [];

    return Provider<WindowHierarchyState>.value(
      value: this,
      updateShouldNotify: (previous, current) => true,
      builder: (context, _) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _dismissOverlay,
              behavior: HitTestBehavior.deferToChild,
              child: widget.rootWindow ?? Container(),
            ),
            GestureDetector(
              onTap: _dismissOverlay,
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                margin: widget.margin,
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
            ),
            ..._overlayEntries
                .map(
                  (e) => DismissibleOverlay(
                    entry: e,
                    key: _overlayKeys[e.id],
                  ),
                )
                .toList(),
            GestureDetector(
              onTap: _dismissOverlay,
              behavior: HitTestBehavior.deferToChild,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.passthrough,
                children: alwaysOnTopWindows,
              ),
            ),
          ],
        );
      },
    );
  }

  void _dismissOverlay() async {
    print("Ok");
    if (_overlayEntries.isNotEmpty) {
      final entry = _overlayEntries.last;
      await entry.animationController.reverse();
      popOverlayEntry(entry);
      setState(() {});
    }
  }

  List<WindowEntry> get entriesByFocus {
    List<WindowEntry> workList = [];

    for (WindowEntryId id in _focusTree) {
      workList.add(_windowEntries.firstWhere((element) => element.id == id));
    }

    return workList;
  }

  /*void _windowSwitcherListener(RawKeyEvent event) {
    if (event.isControlPressed) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (_showWindowSwitcher) {
          requestWindowFocus(entriesByFocus.last);
        } else {
          _showWindowSwitcher = true;
        }
        setState(() {});
      }
    } else {
      _showWindowSwitcher = false;
      setState(() {});
    }
  }*/
}
