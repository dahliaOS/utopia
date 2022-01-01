import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/layout.dart';
import 'entry.dart';
import 'registry.dart';

class WindowHierarchy extends StatefulWidget {
  final WindowHierarchyController controller;
  final LayoutDelegate layoutDelegate;

  const WindowHierarchy({
    required this.controller,
    required this.layoutDelegate,
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
  Rect get _displayBounds => Offset.zero & MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      builder: (context, _) => _LayoutBuilder(
        delegate: widget.layoutDelegate,
        entries: widget.controller.rawEntries,
        focusHierarchy: widget.controller.focusHierarchy,
      ),
    );
  }
}

class _LayoutBuilder extends StatefulWidget {
  final LayoutDelegate delegate;
  final List<LiveWindowEntry> entries;
  final List<String> focusHierarchy;

  const _LayoutBuilder({
    required this.delegate,
    required this.entries,
    required this.focusHierarchy,
    Key? key,
  }) : super(key: key);

  @override
  _LayoutBuilderState createState() => _LayoutBuilderState();
}

class _LayoutBuilderState extends State<_LayoutBuilder> {
  @override
  void didUpdateWidget(covariant _LayoutBuilder old) {
    super.didUpdateWidget(old);

    if (!listEquals(widget.entries, old.entries) ||
        widget.delegate != old.delegate) {
      for (final LiveWindowEntry entry in old.entries) {
        entry.layoutState.removeListener(_listenerCallback);
      }

      for (final LiveWindowEntry entry in widget.entries) {
        entry.layoutState.addListener(_listenerCallback);
      }
    }
  }

  void _listenerCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: widget.delegate.buildAndLayout(
        context,
        widget.entries,
        widget.focusHierarchy,
      ),
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
  List<LiveWindowEntry> get rawEntries => List.unmodifiable(_entries);
  List<String> get focusHierarchy => List.unmodifiable(_focusHierarchy);

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
  Rect get displayBounds => _state._displayBounds;

  List<LiveWindowEntry> get entriesByFocus =>
      WindowEntryUtils.getEntriesByFocus(_entries, _focusHierarchy);

  List<LiveWindowEntry> get sortedEntries =>
      WindowEntryUtils.getSortedEntries(_entries, _focusHierarchy);

  bool isFocused(String id) => WindowEntryUtils.isFocused(_focusHierarchy, id);

  void _checkForInitialized() {
    if (!_initialized) {
      throw Exception(
        "The controller is not bound to any hierarchy or it's not initializated yet",
      );
    }
  }
}

class WindowEntryUtils {
  WindowEntryUtils._();

  static bool isFocused(List<String> focusHierarchy, String id) {
    return focusHierarchy.last == id;
  }

  static List<LiveWindowEntry> getEntriesByFocus(
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  ) {
    final List<LiveWindowEntry> fullscreenEntries =
        entries.where((e) => e.layoutState.fullscreen).toList();
    final List<LiveWindowEntry> alwaysOnTopWindowEntries = entries
        .where(
          (e) =>
              e.layoutState.alwaysOnTop &&
              e.layoutState.alwaysOnTopMode == AlwaysOnTopMode.window &&
              !e.layoutState.fullscreen,
        )
        .toList();
    final List<LiveWindowEntry> alwaysOnTopSysOverlayEntries = entries
        .where(
          (e) =>
              e.layoutState.alwaysOnTop &&
              e.layoutState.alwaysOnTopMode == AlwaysOnTopMode.systemOverlay &&
              !e.layoutState.fullscreen,
        )
        .toList();

    return [
      ...getSortedEntries(entries, focusHierarchy),
      ...alwaysOnTopWindowEntries,
      ...alwaysOnTopSysOverlayEntries,
      ...fullscreenEntries,
    ];
  }

  static List<LiveWindowEntry> getSortedEntries(
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  ) {
    assert(entries.length == focusHierarchy.length);

    final List<LiveWindowEntry> workList = [];

    for (final String id in focusHierarchy) {
      final LiveWindowEntry entry =
          entries.firstWhere((e) => e.registry.info.id == id);
      if (!entry.layoutState.alwaysOnTop && !entry.layoutState.fullscreen) {
        workList.add(entry);
      }
    }

    return workList;
  }
}
