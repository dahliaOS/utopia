import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/entry.dart';
import 'package:utopia_wm/src/events/layout.dart';
import 'package:utopia_wm/src/hierarchy.dart';

/// An abstract class representing a layout delegate for windows.
///
/// Its main responsibility is to lay out windows based on their layout info and focus
/// hierarchy position.
///
/// With this class it is possible to implement any kind of layout, from freeform to
/// tiled to fullscreen.
///
/// In order for this class to work, every window entry it lays out must use the correct
/// [LayoutInfo] subclass for this delegate. For example a [FreeformLayoutDelegate] will
/// require every entry to have a layout info of type [FreeformLayoutInfo].
abstract class LayoutDelegate<T extends LayoutInfo> {
  const LayoutDelegate();

  /// This method is used internally from utopia to build the layout.
  /// It is recommended NOT to override it as there should be no need.
  Widget buildAndLayout(
    BuildContext context,
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  ) {
    assertEntriesMatchRequiredLayoutInfo<T>(entries);
    return layout(context, entries, focusHierarchy);
  }

  /// The main function that decides how entries should be laid out.
  ///
  /// The [entries] and [focusHierarchy] lists are guaranteed to have the same length but it
  /// is not required to return the same amount of received entries.
  ///
  /// It is not required to respect the layout info of the entry as it merely represents
  /// a suggestion of how the window should be laid out.
  Widget layout(
    BuildContext context,
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  );

  /// Makes sure every entry of the [entries] param has a layout info of type [T].
  static void assertEntriesMatchRequiredLayoutInfo<T extends LayoutInfo>(
    List<LiveWindowEntry> entries,
  ) {
    if (entries.any((e) => e.layoutState.info is! T)) {
      throw Exception(
        "One or more window entry don't match the type constraint of $T for layout info",
      );
    }
  }
}

/// An abstract class that represents an immutable structure for a window layout info.
///
/// This class provides some opinionated common properties for any window in any kind of
/// layout.
///
/// Every info this class holds is merely a suggestion for the [LayoutDelegate], which
/// doesn't need to strictly follow what the window would like to be.
/// As such, clients can't have any guarantee about their layout by accessing the
/// fields contained here.
///
/// Refer to [LayoutState] for a mutable and listenable version of this class.
abstract class LayoutInfo {
  /// {@template utopia.layout.LayoutInfo.size}
  /// The size of the window.
  /// {@endtemplate}
  final Size size;

  /// {@template utopia.layout.LayoutInfo.position}
  /// The position of the window.
  /// {@endtemplate}
  final Offset position;

  /// {@template utopia.layout.LayoutInfo.alwaysOnTop}
  /// Whether the window should be over any other window.
  /// {@endtemplate}
  final bool alwaysOnTop;

  /// {@template utopia.layout.LayoutInfo.alwaysOnTopMode}
  /// Whether the always on top should be over other windows but under system overlays
  /// or over these too.
  /// {@endtemplate}
  final AlwaysOnTopMode alwaysOnTopMode;

  /// {@template utopia.layout.LayoutInfo.dock}
  /// The dock for the window. Refer to [WindowDock] for more info.
  /// {@endtemplate}
  final WindowDock dock;

  /// {@template utopia.layout.LayoutInfo.minimized}
  /// Whether the window should be minimized.
  /// {@endtemplate}
  final bool minimized;

  /// {@template utopia.layout.LayoutInfo.fullscreen}
  /// Whether the window should be fullscreen and take over anything else.
  /// {@endtemplate}
  final bool fullscreen;

  /// Const constructor to allow subclasses to be const.
  const LayoutInfo({
    required this.size,
    required this.position,
    required this.alwaysOnTop,
    required this.alwaysOnTopMode,
    required this.dock,
    required this.minimized,
    required this.fullscreen,
  });

  /// This method is required in order to support overriding the layout info from
  /// the [WindowEntry.newInstance] method.
  LayoutInfo copyWith({
    Size? size,
    Offset? position,
    bool? alwaysOnTop,
    AlwaysOnTopMode? alwaysOnTopMode,
    WindowDock? dock,
    bool? minimized,
    bool? fullscreen,
  });

  /// Creates the associated [LayoutState] populating the fields that are needed
  /// for it to properly work. Should not be overridden or used directly, reserved
  /// for the library internal use.
  LayoutState createStateInternal([WindowEventHandler? eventHandler]) {
    final LayoutState state = createState();
    state._info = this;
    state._eventHandler = eventHandler;
    return state;
  }

  /// This method should return a newly created [LayoutState] subclass instance,
  /// similarly to how [StatefulWidget.createState] works.
  @protected
  @factory
  LayoutState createState();
}

/// Abstract class that represent a mutable [LayoutInfo].
///
/// It holds every value present in [LayoutInfo] with the only difference being these
/// are now mutable and will trigger a notification too.
///
/// A subclass of [LayoutState] is associated to a single subclass of [LayoutInfo],
/// and as such it is expected to contain a mutable version of each field the info
/// counterpart held.
abstract class LayoutState<T extends LayoutInfo> extends ChangeNotifier {
  static LayoutState<T> of<T extends LayoutInfo>(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<LayoutState<T>>(context, listen: listen);
  }

  late T _info;

  /// The associated [LayoutInfo] object.
  T get info => _info;

  /// An optional [WindowEventHandler] to notify an eventual listener of layout changes through events.
  WindowEventHandler? _eventHandler;

  late Size _size = info.size;
  late Offset _position = info.position;
  late bool _alwaysOnTop = info.alwaysOnTop;
  late AlwaysOnTopMode _alwaysOnTopMode = info.alwaysOnTopMode;
  late WindowDock _dock = info.dock;
  late bool _minimized = info.minimized;
  late bool _fullscreen = info.fullscreen;

  /// {@macro utopia.layout.LayoutInfo.size}
  Size get size => _size;

  /// {@macro utopia.layout.LayoutInfo.position}
  Offset get position => _position;

  /// Shorthand to generate a [Rect] using the [position] and [size]
  Rect get rect => position & size;

  /// {@macro utopia.layout.LayoutInfo.alwaysOnTop}
  bool get alwaysOnTop => _alwaysOnTop;

  /// {@macro utopia.layout.LayoutInfo.alwaysOnTopMode}
  AlwaysOnTopMode get alwaysOnTopMode => _alwaysOnTopMode;

  /// {@macro utopia.layout.LayoutInfo.dock}
  WindowDock get dock => _dock;

  /// {@macro utopia.layout.LayoutInfo.minimized}
  bool get minimized => _minimized;

  /// {@macro utopia.layout.LayoutInfo.fullscreen}
  bool get fullscreen => _fullscreen;

  /// Sets the current size of the window.
  ///
  /// Generates a [WindowSizeChangeEvent] event.
  set size(Size value) {
    _size = value;
    _eventHandler?.onEvent(
      WindowSizeChangeEvent(
        size: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Sets the current position of the window.
  ///
  /// Generates a [WindowPositionChangeEvent] event.
  set position(Offset value) {
    _position = value;
    _eventHandler?.onEvent(
      WindowPositionChangeEvent(
        position: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Shorthand to set both [position] and [size] using a single [Rect].
  ///
  /// Generates a [WindowPositionChangeEvent] event and [WindowSizeChangeEvent] event.
  set rect(Rect value) {
    if (_position != value.topLeft) {
      _eventHandler?.onEvent(
        WindowPositionChangeEvent(
          position: value.topLeft,
          timestamp: DateTime.now(),
        ),
      );
    }
    _position = value.topLeft;

    if (_size != value.size) {
      _eventHandler?.onEvent(
        WindowSizeChangeEvent(
          size: value.size,
          timestamp: DateTime.now(),
        ),
      );
    }
    _size = value.size;

    notifyListeners();
  }

  /// Sets wether the window should be over any other window.
  ///
  /// Generates a [WindowAlwaysOnTopChangeEvent] event.
  set alwaysOnTop(bool value) {
    _alwaysOnTop = value;
    _eventHandler?.onEvent(
      WindowAlwaysOnTopChangeEvent(
        alwaysOnTop: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Sets whether the always on top should be over other windows but under system overlays
  /// or over these too.
  ///
  /// Generates a [WindowAlwaysOnTopModeChangeEvent] event.
  set alwaysOnTopMode(AlwaysOnTopMode value) {
    _alwaysOnTopMode = value;
    _eventHandler?.onEvent(
      WindowAlwaysOnTopModeChangeEvent(
        alwaysOnTopMode: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Sets the current dock for the window. Refer to [WindowDock] for more info.
  ///
  /// Generates a [WindowDockChangeEvent] event.
  set dock(WindowDock value) {
    _dock = value;
    _eventHandler?.onEvent(
      WindowDockChangeEvent(
        dock: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Sets whether the window should be minimized.
  ///
  /// Generates a [WindowMinimizeEvent] event.
  set minimized(bool value) {
    _minimized = value;
    _eventHandler?.onEvent(
      WindowMinimizeEvent(
        minimized: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Sets whether the window should be fullscreen and take over anything else.
  ///
  /// Generates a [WindowFullscreenEvent] event.
  set fullscreen(bool value) {
    _fullscreen = value;
    _eventHandler?.onEvent(
      WindowFullscreenEvent(
        fullscreen: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}

/// The default [LayoutInfo] provided by the library.
///
/// It is expected to be used in conjuction of [FreeformLayoutDelegate].
class FreeformLayoutInfo extends LayoutInfo {
  /// Create a new instance of [FreeformLayoutInfo] with every parameter being optional.
  const FreeformLayoutInfo({
    super.size = Size.zero,
    super.position = Offset.zero,
    super.alwaysOnTop = false,
    super.alwaysOnTopMode = AlwaysOnTopMode.window,
    super.dock = WindowDock.none,
    super.minimized = false,
    super.fullscreen = false,
  });

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

/// Only exists to have a state counterpart to [FreeformLayoutInfo].
/// By itself has no changes over the asbtract [LayoutState] class.
class FreeformLayoutState extends LayoutState<FreeformLayoutInfo> {}

/// The default [LayoutDelegate] implementation provided by the library.
///
/// It needs every [WindowEntry] living inside to have their layout info be a subclass
/// of [FreeformLayoutInfo].
///
/// This delegate will render every window inside a [Stack] in order to allow them to be
/// fully freeform with docking support, being similar to Windows' DWM.
class FreeformLayoutDelegate extends LayoutDelegate<FreeformLayoutInfo> {
  const FreeformLayoutDelegate();

  @override
  Widget layout(
    BuildContext context,
    List<LiveWindowEntry> entries,
    List<String> focusHierarchy,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: WindowEntryUtils.getEntriesByFocus(entries, focusHierarchy)
          .map((e) => _buildWindow(context, e))
          .toList(),
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

/// An enum representing how always on top windows should behave towards other always on top windows
enum AlwaysOnTopMode {
  /// A window set to be in this mode will be on top only of other windows and
  /// behind system overlays
  window,

  /// If a window is set to be a system overlay then it will be over anything
  /// else, without ever getting something else on top if not other system overlays or fullscreen windows
  systemOverlay,
}

/// An enum representing the type of docking the window should have.
enum WindowDock {
  /// Don't request any particular docking.
  none,

  /// The window should take all the usable viewport but still participate in the focus hierarchy.
  maximized,

  // The window should take all the vertical space and half the horizontal space aligned to the left.
  left,

  // The window should take all the vertical space and half the horizontal space aligned to the right.
  right,

  // The window takes a quarter of the screen space and sits on the top left corner.
  topLeft,

  // The window takes a quarter of the screen space and sits on the top right corner.
  topRight,

  // The window takes a quarter of the screen space and sits on the bottom left corner.
  bottomLeft,

  // The window takes a quarter of the screen space and sits on the bottom right corner.
  bottomRight,
}
