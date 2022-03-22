import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/layout.dart';
import 'package:utopia_wm/src/hierarchy.dart';

abstract class LayoutDelegate<T extends LayoutInfo> {
  const LayoutDelegate();

  Widget buildAndLayout(
    BuildContext context,
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  ) {
    assertEntriesMatchRequiredLayoutInfo<T>(entries);
    return layout(context, entries, focusHierarchy);
  }

  Widget layout(
    BuildContext context,
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  );

  static void assertEntriesMatchRequiredLayoutInfo<T extends LayoutInfo>(
    List<LiveWindowEntry> entries,
  ) {
    if (entries.any((e) => e.layoutState.info is! T)) {
      throw Exception(
        "One or more window entry doesn't match the type constraint of $T for layout info",
      );
    }
  }
}

abstract class LayoutInfo {
  final Size size;
  final Offset position;
  final bool alwaysOnTop;
  final AlwaysOnTopMode alwaysOnTopMode;
  final WindowDock dock;
  final bool minimized;
  final bool fullscreen;

  const LayoutInfo({
    required this.size,
    required this.position,
    required this.alwaysOnTop,
    required this.alwaysOnTopMode,
    required this.dock,
    required this.minimized,
    required this.fullscreen,
  });

  LayoutInfo copyWith({
    Size? size,
    Offset? position,
    bool? alwaysOnTop,
    AlwaysOnTopMode? alwaysOnTopMode,
    WindowDock? dock,
    bool? minimized,
    bool? fullscreen,
  });

  LayoutState createStateInternal([WindowEventHandler? eventHandler]) {
    final LayoutState state = createState();
    state._info = this;
    state._eventHandler = eventHandler;
    return state;
  }

  @protected
  @factory
  LayoutState createState();
}

abstract class LayoutState<T extends LayoutInfo> extends ChangeNotifier {
  static LayoutState<T> of<T extends LayoutInfo>(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<LayoutState<T>>(context, listen: listen);
  }

  T? _info;
  T get info => _info!;

  WindowEventHandler? _eventHandler;

  late Size _size = info.size;
  late Offset _position = info.position;
  late bool _alwaysOnTop = info.alwaysOnTop;
  late AlwaysOnTopMode _alwaysOnTopMode = info.alwaysOnTopMode;
  late WindowDock _dock = info.dock;
  late bool _minimized = info.minimized;
  late bool _fullscreen = info.fullscreen;

  Size get size => _size;
  Offset get position => _position;
  Rect get rect => position & size;
  bool get alwaysOnTop => _alwaysOnTop;
  AlwaysOnTopMode get alwaysOnTopMode => _alwaysOnTopMode;
  WindowDock get dock => _dock;
  bool get minimized => _minimized;
  bool get fullscreen => _fullscreen;

  set size(Size value) {
    _size = value;
    _eventHandler?.onEvent(WindowSizeChangeEvent(
      size: value,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  set position(Offset value) {
    _position = value;
    _eventHandler?.onEvent(WindowPositionChangeEvent(
      position: value,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  set rect(Rect value) {
    if (_position != value.topLeft) {
      _eventHandler?.onEvent(WindowPositionChangeEvent(
        position: value.topLeft,
        timestamp: DateTime.now(),
      ));
    }
    _position = value.topLeft;

    if (_size != value.size) {
      _eventHandler?.onEvent(WindowSizeChangeEvent(
        size: value.size,
        timestamp: DateTime.now(),
      ));
    }
    _size = value.size;

    notifyListeners();
  }

  set alwaysOnTop(bool value) {
    _alwaysOnTop = value;
    _eventHandler?.onEvent(WindowAlwaysOnTopChangeEvent(
      alwaysOnTop: value,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  set alwaysOnTopMode(AlwaysOnTopMode value) {
    _alwaysOnTopMode = value;
    _eventHandler?.onEvent(WindowAlwaysOnTopModeChangeEvent(
      alwaysOnTopMode: value,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  set dock(WindowDock value) {
    _dock = value;
    _eventHandler?.onEvent(WindowDockChangeEvent(
      dock: value,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  set minimized(bool value) {
    _minimized = value;
    _eventHandler?.onEvent(WindowMinimizeEvent(
      minimized: value,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  set fullscreen(bool value) {
    _fullscreen = value;
    _eventHandler?.onEvent(WindowFullscreenEvent(
      fullscreen: value,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}

class FreeformLayoutInfo extends LayoutInfo {
  const FreeformLayoutInfo({
    Size size = Size.zero,
    Offset position = Offset.zero,
    bool alwaysOnTop = false,
    AlwaysOnTopMode alwaysOnTopMode = AlwaysOnTopMode.window,
    WindowDock dock = WindowDock.none,
    bool minimized = false,
    bool fullscreen = false,
  }) : super(
          size: size,
          position: position,
          alwaysOnTop: alwaysOnTop,
          alwaysOnTopMode: alwaysOnTopMode,
          dock: dock,
          minimized: minimized,
          fullscreen: fullscreen,
        );

  @override
  FreeformLayoutState createState() => FreeformLayoutState();

  @override
  FreeformLayoutInfo copyWith({
    Size? size,
    Offset? position,
    bool? alwaysOnTop,
    AlwaysOnTopMode? alwaysOnTopMode,
    WindowDock? dock,
    bool? minimized,
    bool? fullscreen,
  }) {
    return FreeformLayoutInfo(
      size: size ?? this.size,
      position: position ?? this.position,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      alwaysOnTopMode: alwaysOnTopMode ?? this.alwaysOnTopMode,
      dock: dock ?? this.dock,
      minimized: minimized ?? this.minimized,
      fullscreen: fullscreen ?? this.fullscreen,
    );
  }
}

class FreeformLayoutState extends LayoutState<FreeformLayoutInfo> {}

class FreeformLayoutDelegate extends LayoutDelegate<FreeformLayoutInfo> {
  const FreeformLayoutDelegate();

  @override
  Widget layout(
    BuildContext context,
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  ) {
    return Stack(
      children: WindowEntryUtils.getEntriesByFocus(entries, focusHierarchy)
          .map((e) => _buildWindow(context, e))
          .toList(),
      clipBehavior: Clip.none,
    );
  }

  static Widget _buildWindow(BuildContext context, LiveWindowEntry window) {
    final WindowHierarchyController hierarchy = WindowHierarchy.of(context);

    final Rect mqRect;
    final Widget Function(Widget child) builder;

    if (window.layoutState.fullscreen) {
      mqRect = hierarchy.displayBounds;
      builder = (child) => Positioned.fill(child: child);
    } else if (window.layoutState.dock != WindowDock.none) {
      mqRect = hierarchy.wmBounds;
      builder = (child) => Positioned.fromRect(rect: mqRect, child: child);
    } else {
      mqRect = window.layoutState.rect;
      builder = (child) => Positioned.fromRect(rect: mqRect, child: child);
    }

    return builder(
      Offstage(
        offstage: window.layoutState.minimized,
        child: MediaQuery(
          data: MediaQueryData(size: mqRect.size),
          child: window.view,
        ),
      ),
    );
  }
}

enum AlwaysOnTopMode {
  /// A window set to be in this mode will be on top only of other windows and
  /// behind system overlays
  window,

  /// If a window is set to be a system overlay then it will be over anything
  /// else, without ever getting something else on top if not other system overlays or fullscreen windows
  systemOverlay,
}

enum WindowDock {
  none,
  maximized,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
