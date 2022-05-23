import 'package:flutter/material.dart';
import 'package:utopia_wm/src/features/features.dart';
import 'package:utopia_wm/src/registry.dart';

import 'entry.dart';

/// Base class for the properties API for the registry.
///
/// For now it is supposed to be internally used by the lib, as such it doesn't support
/// being implemented, extended or mixed-in.
abstract class WindowPropertiesBase {
  final WindowPropertyRegistry _registry;

  const WindowPropertiesBase._new(this._registry);
}

/// Class that maps the keys from [WindowEntry] using the [WindowPropertiesBase] API.
class InfoWindowProperties extends WindowPropertiesBase {
  const InfoWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  /// Returns the identifier of the window.
  String get id => _registry.get(WindowEntry.id)!;

  /// Returns the current title of the window.
  String get title => _registry.get(WindowEntry.title);

  /// Returns the current icon of the window if available.
  ImageProvider? get icon => _registry.get(WindowEntry.icon);

  /// Returns whether the window is expected to appear inside the WM taskbar.
  bool get showOnTaskbar => _registry.get(WindowEntry.showOnTaskbar);

  /// Sets the window title to the provided [value]. This string could be seen by the user.
  set title(String value) => _registry.set(WindowEntry.title, value);

  /// Sets the window icon to the provided [value]. This icon could be seen by the user.
  set icon(ImageProvider? value) => _registry.set(WindowEntry.icon, value);

  /// Sets whether the window is expected to appear inside the WM taskbar.
  set showOnTaskbar(bool value) =>
      _registry.set(WindowEntry.showOnTaskbar, value);
}

/// Class that maps the keys from [SurfaceWindowFeature] using the [WindowPropertiesBase] API.
class SurfaceWindowProperties extends WindowPropertiesBase {
  const SurfaceWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  /// Returns the shape of the surface of the window. Used for clipping and shadow occlusion.
  ShapeBorder get shape => _registry.get(SurfaceWindowFeature.shape);

  /// Returns the background of the surface of the window.
  Widget get background => _registry.get(SurfaceWindowFeature.background);

  /// Returns the elevation of the surface of the window.
  double get elevation => _registry.get(SurfaceWindowFeature.elevation);

  /// Sets the shape of the surface of the window.
  set shape(ShapeBorder value) =>
      _registry.set(SurfaceWindowFeature.shape, value);

  /// Sets the background of the surface of the window.
  set background(Widget value) =>
      _registry.set(SurfaceWindowFeature.background, value);

  /// Sets the elevation of the surface of the window.
  set elevation(double value) =>
      _registry.set(SurfaceWindowFeature.elevation, value);
}

/// Class that maps the keys from [ResizeWindowFeature] using the [WindowPropertiesBase] API.
class ResizeWindowProperties extends WindowPropertiesBase {
  const ResizeWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  /// Returns the minimum size the window is allowed to be resized to.
  Size get minSize => _registry.get(ResizeWindowFeature.minSize);

  /// Returns the maximum size the window is allowed to be resized to.
  Size get maxSize => _registry.get(ResizeWindowFeature.maxSize);

  /// Returns whether the window currently supports resizing.
  bool get allowResize => _registry.get(ResizeWindowFeature.allowResize);

  /// Sets the minimum size the window is allowed to be resized to.
  set minSize(Size value) => _registry.set(ResizeWindowFeature.minSize, value);

  /// Sets the maximum size the window is allowed to be resized to.
  set maxSize(Size value) => _registry.set(ResizeWindowFeature.maxSize, value);

  /// Sets whether the window currently supports resizing.
  set allowResize(bool value) =>
      _registry.set(ResizeWindowFeature.allowResize, value);
}

/// Class that maps the keys from [ToolbarWindowFeature] using the [WindowPropertiesBase] API.
class ToolbarWindowProperties extends WindowPropertiesBase {
  const ToolbarWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  /// Returns the current vertical size of the toolbar.
  double get size => _registry.get(ToolbarWindowFeature.size);

  /// Returns the current widget used as toolbar.
  Widget get widget => _registry.get(ToolbarWindowFeature.widget);

  /// Sets the current vertical size of the toolbar.
  set size(double value) => _registry.set(ToolbarWindowFeature.size, value);

  /// Sets the current widget used as toolbar.
  set widget(Widget value) => _registry.set(ToolbarWindowFeature.widget, value);
}

/// Class that maps the keys from [FocusableWindowFeature] using the [WindowPropertiesBase] API.
class FocusableWindowProperties extends WindowPropertiesBase {
  const FocusableWindowProperties.mapFrom(WindowPropertyRegistry registry)
      : super._new(registry);

  /// Returns whether the window can actually request the window focus when it gets interacted with.
  bool get canRequest => _registry.get(FocusableWindowFeature.canRequest);

  /// Sets whether the window can request the window focus when it gets interacted with.
  set canRequest(bool value) =>
      _registry.set(FocusableWindowFeature.canRequest, value);
}
