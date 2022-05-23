import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'properties.dart';

typedef WindowProperties = Map<WindowPropertyKey, Object?>;

/// Represents a per-window registry containing info about the window itself.
/// It holds a [Map] of [WindowPropertyKey]s with an object associated for each.
///
/// Keys specific to a feature are usually defined as static properties of the feature class itself.
/// It's not usually recommended to access data directly from the registry but to instead
/// the various helpers provided by the extension [RegistryUtils].
class WindowPropertyRegistry with ChangeNotifier {
  final WindowProperties _data = {};

  /// Create a new [WindowPropertyRegistry]. Usually users should have no need to create
  /// a registry manually as it is automatically provided by a [LiveWindowEntry].
  ///
  /// It is possible to pass some [initialData] that allows to pass initial keys to the registry
  /// and also to define readonly keys.
  WindowPropertyRegistry({WindowProperties initialData = const {}}) {
    _data.addAll(initialData);
  }

  /// Get the value the registry eventually holds for the [key].
  /// If the key is not present then the default value for the key will be returned.
  T get<T>(WindowPropertyKey<T> key) {
    return _data[key] as T? ?? key.defaultValue;
  }

  /// Returns the value inside the registry associated with the [key] only if present,
  /// return null if the key isn't present.
  T? maybeGet<T>(WindowPropertyKey<T?> key) {
    return _data[key] as T?;
  }

  /// Inserts or modifies [key] inside the registry with the [value] passed.
  /// If [notify] is true then the registry will notify every listener of the change.
  ///
  /// Editing or inserting readonly keys is not allowed. In order to add a readonly key,
  /// pass it to the [WindowPropertyRegistry] constructor.
  ///
  /// It is possible to pass null to [value] in order to remove the key from the registry,
  /// but only if the key type doesn't allow nullable values.
  void set<T>(WindowPropertyKey<T> key, T? value, {bool notify = true}) {
    if (key.readonly) {
      throw Exception('Cannot edit a readonly property: ${key.name}');
    }

    _data[key] = value;
    if (notify) {
      notifyListeners();
    }
  }

  /// Checks if the registry currently holds any value for the [key]
  bool hasProperty<T>(WindowPropertyKey<T> key) {
    return _data.containsKey(key);
  }

  /// Allows to access the currently associated registry for the window.
  /// It is guaranteed to return a proper instance if accessed inside a [context] derived from a window.
  /// Usually any [WindowFeature] will allow to access a registry.
  static WindowPropertyRegistry of(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<WindowPropertyRegistry>(context, listen: listen);
  }
}

/// Represents a key for a value inside a [WindowPropertyRegistry].
/// It is strongly typed using a type parameter [T] that is used for the associated value
/// in the registry and also for the key [defaultValue], used if no value for the key
/// could be returned.
///
/// Each key is identified by a [name] that is usually in the format of <scope>.<name>.<property>.
/// For example, the minSize property of the ResizeWindowFeature will be represented with
/// a key with name feature.resize.minSize.
///
/// It is possible to declare if a key is [readonly], denying any modification made once the registry
/// is created.
class WindowPropertyKey<T> {
  /// The identifier of the key. Usually in the format of <scope>.<name>.<property>.
  /// For example, the minSize property of the ResizeWindowFeature will be represented with
  /// a key with name feature.resize.minSize.
  final String name;

  /// The default value of the key, used when the registry doesn't contain any other value.
  final T defaultValue;

  /// Whether the key is readonly inside the registry. By default this field is false.
  final bool readonly;

  const WindowPropertyKey(
    this.name,
    this.defaultValue, {
    this.readonly = false,
  });

  @override
  String toString() {
    return 'NAME $name DEFAULT $defaultValue';
  }
}

/// Exposes a strongly typed api for the common properties that can be accessed from the registry.
/// Everything can be accessed even if the associated feature is not used by the window.
/// In that case, null will be returned for any property of the missing feature.
extension RegistryUtils on WindowPropertyRegistry {
  InfoWindowProperties get info => InfoWindowProperties.mapFrom(this);

  SurfaceWindowProperties get surface => SurfaceWindowProperties.mapFrom(this);

  ResizeWindowProperties get resize => ResizeWindowProperties.mapFrom(this);

  ToolbarWindowProperties get toolbar => ToolbarWindowProperties.mapFrom(this);

  FocusableWindowProperties get focusable =>
      FocusableWindowProperties.mapFrom(this);
}
