import 'package:flutter/material.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/registry.dart';

class MinimizeWindowFeature extends WindowFeature {
  static const WindowPropertyKey<bool> minimized =
      WindowPropertyKey<bool>('feature.minimize.minimized', false);

  const MinimizeWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);

    return Offstage(offstage: properties.minimize.minimized, child: content);
  }

  @override
  List<WindowPropertyKey> get requiredProperties => [];
}
