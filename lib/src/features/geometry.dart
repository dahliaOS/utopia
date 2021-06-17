import 'package:flutter/widgets.dart';
import 'package:utopia_wm/src/hierarchy.dart';
import 'package:utopia_wm/src/registry.dart';

import 'base.dart';

class GeometryWindowFeature extends WindowFeature {
  static const WindowPropertyKey<Size> size =
      WindowPropertyKey<Size>('feature.geometry.size', Size.zero);
  static const WindowPropertyKey<Offset> position =
      WindowPropertyKey<Offset>('feature.geometry.position', Offset.zero);
  static const WindowPropertyKey<bool> maximized =
      WindowPropertyKey<bool>('feature.geometry.maximized', false);

  const GeometryWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);
    final WindowHierarchyController hierarchy = WindowHierarchy.of(context);

    return CustomSingleChildLayout(
      delegate: WindowGeometryDelegate(
        !properties.geometry.maximized
            ? properties.geometry.rect
            : hierarchy.wmBounds,
      ),
      child: MediaQuery(
        data: MediaQueryData(
          size: !properties.geometry.maximized
              ? properties.geometry.size
              : hierarchy.wmBounds.size,
        ),
        child: content,
      ),
    );
  }

  @override
  List<WindowPropertyKey> get requiredProperties => [size, position];
}

class WindowGeometryDelegate extends SingleChildLayoutDelegate {
  final Rect windowRect;

  const WindowGeometryDelegate(this.windowRect);

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tight(windowRect.size);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return windowRect.topLeft;
  }

  @override
  bool shouldRelayout(WindowGeometryDelegate old) {
    return windowRect != old.windowRect;
  }
}
