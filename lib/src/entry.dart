import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/events/base.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/layout.dart';
import 'package:uuid/uuid.dart';

import 'registry.dart';

/// Base class for any window inside the WM itself.
///
/// Every property is considered "dry" along with the class instance itself, as such
/// it is possible to have completely constant entries.
///
/// A [WindowEntry] in itself doesn't do anything, it just acts as a generic structure to use
/// to create new windows using the [newInstance] method. This allows you to get an instance
/// of the associated [LiveWindowEntry].
class WindowEntry {
  /// Registry key for the window id. This identifier should be unique across the WM
  /// and as such it is suggested to not define it manually.
  static const WindowPropertyKey<String?> id =
      WindowPropertyKey('window.id', null, readonly: true);

  /// Registry key for the window title.
  static const WindowPropertyKey<String> title =
      WindowPropertyKey('window.title', 'Window');

  /// Registry key for the window icon. It uses flutter ImageProvider so it can
  /// be an asset, a file, a network image and more.
  static const WindowPropertyKey<ImageProvider?> icon =
      WindowPropertyKey('window.icon', null);

  /// Registry key for whether to show the window on the taskbar or not. The only
  /// effect it has on the WM itself is to be a discriminant for returning window
  /// entries on particular getters.
  static const WindowPropertyKey<bool> showOnTaskbar =
      WindowPropertyKey('window.showOnTaskbar', true);

  /// The initial layout configuration of the window. Usually will contain a subclass
  /// of the abstract [LayoutInfo] class. Check its docs for more.
  final LayoutInfo layoutInfo;

  /// A [List] of [WindowFeature]s that make up the capabilities and look of the window.
  /// It is important to note that the order they are in is important as the first feature
  /// wraps every other feature in the list and so on, recursively.
  /// This means that some features could depend on other features to be present before
  /// or after.
  final List<WindowFeature> features;

  /// The initial properties of the window, defined as a [Map] of [WindowPropertyKey]s
  /// and [Object]s.
  final WindowProperties properties;

  /// Create a new [WindowEntry].
  /// It is recommended that any instance is created as const.
  const WindowEntry({
    required this.layoutInfo,
    required this.features,
    required this.properties,
  });

  /// Create a new [LiveWindowEntry] based on this [WindowEntry].
  ///
  /// Allows to pass a [content] param to use as the window content. If null, the
  /// window will just be a frame built using the passed features with the specified layout.
  ///
  /// It is also possible to pass an [eventHandler] to receive and react to window-generated
  /// events, like move, resize, and more.
  ///
  /// [overrideLayout] and [overrideProperties] allow to pass overrides for the layout and
  /// registry info present in the entry fields.
  ///
  /// A window must contain a [WindowEntry.id] key (if absent it'll be generated)
  /// and a [WindowEntry.title] key.
  LiveWindowEntry newInstance({
    Widget? content,
    WindowEventHandler? eventHandler,
    LayoutInfo Function(LayoutInfo info)? overrideLayout,
    Map<WindowPropertyKey, Object?> overrideProperties = const {},
  }) {
    final Map<WindowPropertyKey, Object?> completedProperties =
        Map.of(properties)
          ..addAll(overrideProperties)
          ..putIfAbsent(id, () => const Uuid().v4());
    assert(completedProperties.containsKey(id) &&
        completedProperties.containsKey(title));

    final LayoutInfo info = overrideLayout?.call(layoutInfo) ?? layoutInfo;

    return LiveWindowEntry._(
      content: content ?? const SizedBox(),
      layoutState: info.createStateInternal(eventHandler),
      features: features,
      eventHandler: eventHandler,
      registry: WindowPropertyRegistry(initialData: completedProperties),
    );
  }
}

/// Active representation of a [WindowEntry] instance.
///
/// It can't be directly instantiated but must be created using the [WindowEntry.newInstance]
/// method.
///
/// The [layoutState] field contains a mutable representation of the window layout.
/// It's possible to get the final window view by accessing the [view] getter.
///
/// This view provides access to the window [WindowPropertyRegistry], [LayoutState] and [WindowEventHandler]
/// through different providers.
class LiveWindowEntry {
  /// The raw window content passed from the [WindowEntry.newInstance] method, stored as is.
  /// Usually it is not recommended to access this field directly and it is suggested
  /// to use the [view] getter to get the completed built window.
  final Widget content;

  /// The active state of the window, created by applying the overrides from the
  /// [WindowEntry.newInstance] method to the [WindowEntry] layoutInfo.
  ///
  /// It is recommended to access this field using the exposed provider if possible.
  final LayoutState layoutState;

  /// The [WindowFeature]s of the window, created by applying the overrides from the
  /// [WindowEntry.newInstance] method to the [WindowEntry] features.
  final List<WindowFeature> features;

  /// The mutable property registry of the window, generated by passing the initial
  /// properties created byapplying the overrides from the [WindowEntry.newInstance]
  /// method to the [WindowEntry] properties.
  ///
  /// It is recommended to access this field using the exposed provider if possible.
  final WindowPropertyRegistry registry;

  /// An optional event handler for the window events.
  ///
  /// It is recommended to access this field using the exposed provider if possible.
  final WindowEventHandler? eventHandler;
  bool _disposed = false;

  Widget? _view;

  /// The window widget created by combining the features with the content.
  ///
  /// You can access this only as long as this [LiveWindowEntry] is not disposed.
  /// It relies on a cached widget that is created automatically at class instantiation
  /// and disposed when the window gets removed from the hierarchy.
  Widget get view {
    if (_disposed || _view == null) {
      throw Exception(
        'This LiveWindowEntry has been disposed and cannot be used anymore: ${registry.info.id}',
      );
    }
    return _view!;
  }

  LiveWindowEntry._({
    required this.content,
    required this.layoutState,
    required this.features,
    required this.registry,
    this.eventHandler,
  }) : _view = MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: registry),
            ChangeNotifierProvider.value(value: layoutState),
            Provider.value(value: eventHandler),
          ],
          child: WindowWrapper(
            features: features,
            content: content,
            key: ValueKey(registry.info.id),
          ),
          key: GlobalKey(),
        );

  /// Dispose the created view and invalidate the entry.
  /// It is not recommended to call this method directly as the WM itself will handle
  /// disposal when needed.
  void dispose() {
    _view = null;
    _disposed = true;
  }
}

/// Simple wrapper that builds the window frame around the [content] using the passed [features].
///
/// It should not be used directly, it is expected to be used only by [LiveWindowEntry].
class WindowWrapper extends StatefulWidget {
  final List<WindowFeature> features;
  final Widget content;

  const WindowWrapper({
    required this.features,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  _WindowWrapperState createState() => _WindowWrapperState();
}

class _WindowWrapperState extends State<WindowWrapper> {
  @override
  void initState() {
    super.initState();

    final registry = WindowPropertyRegistry.of(context, listen: false);
    for (WindowFeature feature in widget.features) {
      for (WindowPropertyKey property in feature.requiredProperties) {
        bool contains = registry.hasProperty(property);
        if (!contains) {
          throw Exception(
            'The required property ${property.name} was not found for the feature ${feature.runtimeType}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildFeatures(context);

  Widget _buildFeatures(BuildContext context, [int index = 0]) {
    if (index >= widget.features.length) {
      return SizedBox.expand(child: widget.content);
    }

    return widget.features[index]
        .build(context, _buildFeatures(context, index + 1));
  }
}

/// Abstract class for an event handler for a [LiveWindowEntry].
///
/// Allows to receive and respond to window generated events by overriding the [onEvent]
/// method or by mixing in the various event helpers provided by the lib, like
/// [ResizeEvents] or [LayoutEvents].
abstract class WindowEventHandler {
  LiveWindowEntry? _entry;

  /// The entry this event handler is associated with.
  LiveWindowEntry get entry => _entry!;

  /// Overriding this method allows to receive and react to an event.
  /// In order to react you just return the handler.
  ///
  /// It is required to call `super.onEvent` at the end of the method body to properly
  /// call [onUnhandled].
  @mustCallSuper
  void onEvent(WindowEvent event) {
    onUnhandled(event);
  }

  /// This method can be overridden to react to any event that wasn't handled directly
  /// by the [onEvent] method.
  void onUnhandled(WindowEvent event) {}

  /// Obtain the [WindowEventHandler] associated with the [LiveWindowEntry] if present.
  static WindowEventHandler? maybeOf(BuildContext context) {
    return Provider.of<WindowEventHandler?>(context, listen: false);
  }
}
