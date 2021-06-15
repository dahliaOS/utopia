import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'properties.dart';

//typedef WindowProperties = Map<WindowPropertyKey, Object?>;

class WindowPropertyRegistry with ChangeNotifier {
  final Map<WindowPropertyKey, Object?> _data = {};

  WindowPropertyRegistry(
      {Map<WindowPropertyKey, Object?> initialData = const {}}) {
    _data.addAll(initialData);
  }

  T get<T>(WindowPropertyKey<T> key) {
    return _data[key] as T? ?? key.defaultValue;
  }

  T? maybeGet<T>(WindowPropertyKey<T?> key) {
    return _data[key] as T? ?? key.defaultValue;
  }

  void set<T>(WindowPropertyKey<T> key, T? value, {bool notify = true}) {
    if (key.readonly) {
      throw Exception('Cannot edit a readonly property: ${key.name}');
    }
    //print("EDIT KEY $key CURRENT VALUE ${_data[key]} NEW VALUE $value");
    _data[key] = value;
    if (notify) {
      notifyListeners();
    }
  }

  bool hasProperty<T>(WindowPropertyKey<T> key) {
    return _data.containsKey(key);
  }

  static WindowPropertyRegistry of(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<WindowPropertyRegistry>(context, listen: listen);
  }
}

class WindowPropertyKey<T> {
  final String name;
  final T defaultValue;
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

extension RegistryUtils on WindowPropertyRegistry {
  InfoWindowProperties get info => InfoWindowProperties.mapFrom(this);

  GeometryWindowProperties get geometry =>
      GeometryWindowProperties.mapFrom(this);

  SurfaceWindowProperties get surface => SurfaceWindowProperties.mapFrom(this);

  ResizeWindowProperties get resize => ResizeWindowProperties.mapFrom(this);

  ToolbarWindowProperties get toolbar => ToolbarWindowProperties.mapFrom(this);

  FocusableWindowProperties get focusable =>
      FocusableWindowProperties.mapFrom(this);
}
