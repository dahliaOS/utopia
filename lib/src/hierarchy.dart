import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'entry.dart';
import 'registry.dart';

class WindowHierarchy extends StatefulWidget {
  final WindowHierarchyController controller;

  const WindowHierarchy({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  _WindowHierarchyState createState() => _WindowHierarchyState();

  static WindowHierarchyController of(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<WindowHierarchyController>(context, listen: listen);
  }
}

class _WindowHierarchyState extends State<WindowHierarchy> {
  @override
  void initState() {
    super.initState();
    widget.controller._provideState(this);
  }

  void _requestRebuild() {
    setState(() {});
  }

  Rect get _wmBounds => widget.controller.wmInsets
      .deflateRect(Offset.zero & MediaQuery.of(context).size);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      builder: (context, child) {
        return Stack(
          children:
              widget.controller.entriesByFocus.map((e) => e.view).toList(),
          clipBehavior: Clip.none,
        );
      },
    );
  }
}

class WindowHierarchyController with ChangeNotifier {
  late final _WindowHierarchyState _state;
  bool _initialized = false;
  final List<LiveWindowEntry> _entries = [];
  final List<String> _focusHierarchy = [];
  EdgeInsets _wmInsets = EdgeInsets.zero;

  WindowHierarchyController();

  List<LiveWindowEntry> get entries => _entries
      .where(
        (e) => e.registry.info.showOnTaskbar,
      )
      .toList();

  void _provideState(_WindowHierarchyState state) {
    _state = state;
    _initialized = true;
  }

  void addWindowEntry(LiveWindowEntry entry) {
    _checkForInitialized();
    _entries.add(entry);
    _focusHierarchy.add(entry.registry.info.id);
    notifyListeners();
    _state._requestRebuild();
  }

  void removeWindowEntry(String id) {
    _checkForInitialized();
    final int entryIndex =
        _entries.indexWhere((element) => element.registry.info.id == id);
    _entries.removeAt(entryIndex).dispose();
    _focusHierarchy.remove(id);
    notifyListeners();
    _state._requestRebuild();
  }

  void requestEntryFocus(String id) {
    _checkForInitialized();
    final int idIndex = _focusHierarchy.indexWhere((element) => element == id);
    final String poppedId = _focusHierarchy.removeAt(idIndex);
    _focusHierarchy.add(poppedId);
    notifyListeners();
    _state._requestRebuild();
  }

  EdgeInsets get wmInsets => _wmInsets;
  set wmInsets(EdgeInsets value) {
    _wmInsets = value;
    notifyListeners();
  }

  Rect get wmBounds => _state._wmBounds;

  List<LiveWindowEntry> get entriesByFocus {
    final List<LiveWindowEntry> alwaysOnTopWindowEntries = _entries
        .where(
          (e) =>
              e.registry.info.alwaysOnTop &&
              e.registry.info.alwaysOnTopMode == AlwaysOnTopMode.window,
        )
        .toList();
    final List<LiveWindowEntry> alwaysOnTopSysOverlayEntries = _entries
        .where(
          (e) =>
              e.registry.info.alwaysOnTop &&
              e.registry.info.alwaysOnTopMode == AlwaysOnTopMode.systemOverlay,
        )
        .toList();

    return [
      ...normalEntries,
      ...alwaysOnTopWindowEntries,
      ...alwaysOnTopSysOverlayEntries,
    ];
  }

  List<LiveWindowEntry> get normalEntries {
    final List<LiveWindowEntry> workList = [];

    for (final String id in _focusHierarchy) {
      final LiveWindowEntry entry =
          _entries.firstWhere((e) => e.registry.info.id == id);
      if (!entry.registry.info.alwaysOnTop) {
        workList.add(entry);
      }
    }

    return workList;
  }

  bool isFocused(String id) {
    return _focusHierarchy.last == id;
  }

  void _checkForInitialized() {
    if (!_initialized) {
      throw Exception(
        "The controller is not bound to any hierarchy or it's not initializated yet",
      );
    }
  }
}
