import 'package:flutter/material.dart';
import 'package:utopia_wm/src/hierarchy.dart';
import 'package:utopia_wm/src/registry.dart';

import 'base.dart';

class FocusableWindowFeature extends WindowFeature {
  static const WindowPropertyKey<bool> canRequest =
      WindowPropertyKey('features.focusable.canRequest', true);

  const FocusableWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);

    return Listener(
      onPointerDown: properties.focusable.canRequest
          ? (event) {
              WindowHierarchy.of(context, listen: false)
                  .requestEntryFocus(properties.info.id);
            }
          : null,
      behavior: HitTestBehavior.translucent,
      child: content,
    );
  }

  @override
  List<WindowPropertyKey> get requiredProperties => [];
}
