import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/layout.dart';
import 'entry.dart';
import 'registry.dart';

/// The class that is responsible of actually building the windows using the provided [layoutDelegate].
///
/// It needs a [WindowHierarchyController], an object that contains the current
/// state of the window manager and provides a way to interact with the wm from outside,
/// and a [LayoutDelegate], the class responsible of laying out the windows the wm contains.
class WindowHierarchy extends StatelessWidget {
  final WindowHierarchyController controller;
  final LayoutDelegate layoutDelegate;

  const WindowHierarchy({
    required this.controller,
    required this.layoutDelegate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return _WindowHierarchyInternal(
        controller: controller,
        layoutDelegate: layoutDelegate,
        size: constraints.biggest,
      );
    });
  }

  /// Obtain the current [WindowHierarchyController] exposed by this widget via a provider.
  static WindowHierarchyController of(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<WindowHierarchyController>(context, listen: listen);
  }
}

class _WindowHierarchyInternal extends StatefulWidget {
  final WindowHierarchyController controller;
  final LayoutDelegate layoutDelegate;
  final Size size;

  const _WindowHierarchyInternal({
    required this.controller,
    required this.layoutDelegate,
    required this.size,
  });

  @override
  State<_WindowHierarchyInternal> createState() =>
      _WindowHierarchyInternalState();
}

class _WindowHierarchyInternalState extends State<_WindowHierarchyInternal> {
  @override
  void initState() {
    super.initState();
    widget.controller._provideState(this);
  }

  void _requestRebuild() {
    setState(() {});
  }

  Rect get _wmBounds => widget.controller.wmInsets.deflateRect(_displayBounds);
  Rect get _displayBounds => Offset.zero & widget.size;

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

/// The heart of the [WindowHierarchy].
///
/// This class is responsible of holding the actual state and status of the windows and of the
/// wm itself.
///
/// It contains the current window [entries], the [focusHierarchy] that dictates the order
/// the windows should be rendered and the [wmInsets] that define areas that should not be
/// occluded by windows for stuff like system overlays and such.
class WindowHierarchyController with ChangeNotifier {
  late final _WindowHierarchyInternalState _state;
  bool _initialized = false;

  final List<LiveWindowEntry> _entries = [];
  final List<String> _focusHierarchy = [];
  EdgeInsets _wmInsets = EdgeInsets.zero;

  /// Returns every window that is allowed to be shown on an eventual taskbar.
  ///
  /// To get the list of every single entry without filters use [rawEntries].
  List<LiveWindowEntry> get entries => _entries
      .where(
        (e) => e.registry.info.showOnTaskbar,
      )
      .toList();

  /// Returns the raw contents of the internally managed entry list of the controller.
  List<LiveWindowEntry> get rawEntries => List.unmodifiable(_entries);

  /// Returns the focus hierarchy of the currently shown windows. This list is
  /// guaranteed to have as many items as [rawEntries].
  List<String> get focusHierarchy => List.unmodifiable(_focusHierarchy);

  void _provideState(_WindowHierarchyInternalState state) {
    _state = state;
    _initialized = true;
  }

  /// Push a [LiveWindowEntry] onto the window hierarchy, placing it on top of every
  /// other window.
  ///
  /// The controller will need to be connected to a [WindowHierarchy] in order for this method to work.
  void addWindowEntry(LiveWindowEntry entry) {
    _checkForInitialized();
    _entries.add(entry);
    _focusHierarchy.add(entry.registry.info.id);
    notifyListeners();
    _state._requestRebuild();
  }

  /// Remove a [LiveWindowEntry] by using its [id]. If no entry with that specific id
  /// is found then no window is removed.
  ///
  /// The controller will need to be connected to a [WindowHierarchy] in order for this method to work.
  void removeWindowEntry(String id) {
    _checkForInitialized();
    final int entryIndex =
        _entries.indexWhere((element) => element.registry.info.id == id);
    _entries.removeAt(entryIndex).dispose();
    _focusHierarchy.remove(id);
    notifyListeners();
    _state._requestRebuild();
  }

  /// Requests that a [LiveWindowEntry] gets pushed over any other window by using the
  /// entry [id].
  ///
  /// The controller will need to be connected to a [WindowHierarchy] in order for this method to work.
  void requestEntryFocus(String id) {
    _checkForInitialized();
    final int idIndex = _focusHierarchy.indexWhere((element) => element == id);
    final String poppedId = _focusHierarchy.removeAt(idIndex);
    _focusHierarchy.add(poppedId);
    notifyListeners();
    _state._requestRebuild();
  }

  /// The insets of the wm that define areas that should not be
  /// occluded by windows for stuff like system overlays and such.
  EdgeInsets get wmInsets => _wmInsets;
  set wmInsets(EdgeInsets value) {
    _wmInsets = value;
    notifyListeners();
  }

  /// Returns the actual bounds of the [WindowHierarchy] which equals to the size
  /// of the hierarchy itself minus the [wmInsets].
  Rect get wmBounds => _state._wmBounds;

  /// Returns the total size that the [WindowHierarchy] takes to render.
  Rect get displayBounds => _state._displayBounds;

  /// {@macro utopia.hierarchy.WindowEntryUtils.entriesByFocus}
  List<LiveWindowEntry> get entriesByFocus =>
      WindowEntryUtils.getEntriesByFocus(_entries, _focusHierarchy);

  /// {@macro utopia.hierarchy.WindowEntryUtils.sortedEntries}
  List<LiveWindowEntry> get sortedEntries =>
      WindowEntryUtils.getSortedEntries(_entries, _focusHierarchy);

  /// {@macro utopia.hierarchy.WindowEntryUtils.isFocused}
  bool isFocused(String id) => WindowEntryUtils.isFocused(_focusHierarchy, id);

  void _checkForInitialized() {
    if (!_initialized) {
      throw Exception(
        "The controller is not bound to any hierarchy or it's not initializated yet",
      );
    }
  }
}

/// Static class that contains some utilities to work with [LiveWindowEntry] and focus
/// hierarchies. Cannot be instantiated as every method is supposed to be static.
class WindowEntryUtils {
  const WindowEntryUtils._();

  /// {@template utopia.hierarchy.WindowEntryUtils.isFocused}
  /// Will check if the specified [id] is the last (focused) inside the [focusHierarchy].
  /// If it is, returns `true`.
  /// {@endtemplate}
  static bool isFocused(List<String> focusHierarchy, String id) {
    return focusHierarchy.last == id;
  }

  /// {@template utopia.hierarchy.WindowEntryUtils.entriesByFocus}
  /// Will return the provided [entries] sorted using the [focusHierarchy] and
  /// order them in this order:
  /// - Normal entries (neither fullscreen nor always on top)
  /// - Always on top windows
  /// - Always on top as system overlay windows
  /// - Fullscreen windows
  /// {@endtemplate}
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

  /// {@template utopia.hierarchy.WindowEntryUtils.sortedEntries}
  /// Returns [entries] sorted based on the [focusHierarchy] by checking if
  /// the entry isn't fullscreen or set to always on top, as these don't actually
  /// participate in the focus hierarchy.
  /// {@endtemplate}
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
