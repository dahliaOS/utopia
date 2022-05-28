import 'package:flutter/material.dart';
import 'package:utopia_wm/src/hierarchy.dart';
import 'package:utopia_wm/src/registry.dart';

import 'base.dart';

/// [WindowFeature] to make the window get focus if it gets clicked/tapped.
class FocusableWindowFeature extends WindowFeature {
  /// Registry key to check if the window can actually request the window
  /// focus when it gets interacted with. Defaults to `true`.
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
}
