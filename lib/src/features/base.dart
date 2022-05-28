import 'package:flutter/widgets.dart';
import 'package:utopia_wm/wm.dart';

/// The base class for any feature of a window.
///
/// A [WindowFeature] is a class that builds around the window to add functionality
/// or change its looks.
///
/// It builds in a recursive manner where the first added feature wraps every other
/// in the feature list, making it possible to depend on some features being present.
///
/// From the [build] method you can access and listen to every provider exposed by [LiveWindowEntry],
/// such as [WindowPropertyRegistry], [LayoutState] and [WindowEventHandler].
///
/// Features should hold no fields or state and instead should use and listen to
/// the context [WindowPropertyRegistry] inside the [build] method.
/// Also, it is common practice to add the [WindowPropertyKey]s the feature uses
/// as static fields of the subclass.
abstract class WindowFeature {
  /// Const constructor for subclasses, usually it is expected to not have any param
  /// as anything needed by the feature should be provided using the [WindowPropertyRegistry].
  const WindowFeature();

  /// The method builds the actual feature, from visuals to functionality.
  ///
  /// It is expected to always return the [content] provided to it, whether as is
  /// or wrapped by some other widget.
  ///
  /// The provided [context] comes directly from the window [LiveWindowEntry], allowing
  /// to use any exposed provider to it.
  Widget build(BuildContext context, Widget content);

  /// A list of properties required to be present in the registry in order for the feature to
  /// work properly. If any of these is absent the [WindowWrapper] building the features
  /// will throw an Exception.
  Set<WindowPropertyKey> get requiredProperties => {};
}
