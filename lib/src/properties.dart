import 'package:flutter/material.dart';
import 'package:utopia_wm/src/features/features.dart';
import 'package:utopia_wm/src/registry.dart';

import 'entry.dart';

abstract class WindowPropertiesBase {
  final WindowPropertyRegistry _registry;

  const WindowPropertiesBase._new(this._registry);
}

class InfoWindowProperties extends WindowPropertiesBase {
  const InfoWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  String get id => _registry.get(WindowEntry.id)!;
  String get title => _registry.get(WindowEntry.title);
  ImageProvider? get icon => _registry.get(WindowEntry.icon);
  bool get showOnTaskbar => _registry.get(WindowEntry.showOnTaskbar);

  set title(String value) => _registry.set(WindowEntry.title, value);
  set icon(ImageProvider? value) => _registry.set(WindowEntry.icon, value);
}

class SurfaceWindowProperties extends WindowPropertiesBase {
  const SurfaceWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  ShapeBorder get shape => _registry.get(SurfaceWindowFeature.shape);
  Widget get background => _registry.get(SurfaceWindowFeature.background);
  double get elevation => _registry.get(SurfaceWindowFeature.elevation);

  set shape(ShapeBorder value) =>
      _registry.set(SurfaceWindowFeature.shape, value);
  set background(Widget value) =>
      _registry.set(SurfaceWindowFeature.background, value);
  set elevation(double value) =>
      _registry.set(SurfaceWindowFeature.elevation, value);
}

class ResizeWindowProperties extends WindowPropertiesBase {
  const ResizeWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  Size get minSize => _registry.get(ResizeWindowFeature.minSize);
  Size get maxSize => _registry.get(ResizeWindowFeature.maxSize);
  bool get allowResize => _registry.get(ResizeWindowFeature.allowResize);

  set minSize(Size value) => _registry.set(ResizeWindowFeature.minSize, value);
  set maxSize(Size value) => _registry.set(ResizeWindowFeature.maxSize, value);
  set allowResize(bool value) =>
      _registry.set(ResizeWindowFeature.allowResize, value);
}

class ToolbarWindowProperties extends WindowPropertiesBase {
  const ToolbarWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  double get size => _registry.get(ToolbarWindowFeature.size);
  Widget get widget => _registry.get(ToolbarWindowFeature.widget);

  set size(double value) => _registry.set(ToolbarWindowFeature.size, value);
  set widget(Widget value) => _registry.set(ToolbarWindowFeature.widget, value);
}

class FocusableWindowProperties extends WindowPropertiesBase {
  const FocusableWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  bool get canRequest => _registry.get(FocusableWindowFeature.canRequest);

  set canRequest(bool value) =>
      _registry.set(FocusableWindowFeature.canRequest, value);
}
