import 'package:flutter/widgets.dart';
import 'package:utopia_wm/wm.dart';

class ApplicationEntry {
  final String id;
  final String name;
  final String? description;
  final ImageProvider? icon;
  final Widget entryPoint;
  final WindowProperties? overrideProperties;
  final LayoutInfoOverrideCallback? overrideLayout;

  const ApplicationEntry({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.entryPoint,
    this.overrideProperties,
    this.overrideLayout,
  });
}
