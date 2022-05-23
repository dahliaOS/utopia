import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/layout.dart';
import 'package:utopia_wm/src/registry.dart';

/// A [WindowFeature] that provides a background surface for the window to sit on.
///
/// It is possible to override the shape, the widget and the elevation of the surface.
class SurfaceWindowFeature extends WindowFeature {
  /// Registry key that holds the shape of the window. It is used for clipping and
  /// shadow occluding. Defaults to [RoundedRectangleBorder].
  static const WindowPropertyKey<ShapeBorder> shape =
      WindowPropertyKey('feature.surface.shape', RoundedRectangleBorder());

  /// Registry key that holds the widget that is used as surface.
  /// Defaults to [DefaultWindowBackground].
  static const WindowPropertyKey<Widget> background = WindowPropertyKey(
    'feature.surface.background',
    DefaultWindowBackground(),
  );

  /// Registry key that holds the amount of elevation of the surface.
  /// Defaults to `0`.
  static const WindowPropertyKey<double> elevation =
      WindowPropertyKey('feature.surface.elevation', 0);

  const SurfaceWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);
    final LayoutState layout = LayoutState.of(context);

    final ShapeBorder shape =
        layout.dock != WindowDock.none || layout.fullscreen
            ? const RoundedRectangleBorder()
            : properties.surface.shape;

    return _ShadowOccluder(
      shape: shape,
      elevation: properties.surface.elevation,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(child: properties.surface.background),
            Positioned.fill(child: content),
          ],
        ),
      ),
    );
  }

  @override
  List<WindowPropertyKey> get requiredProperties => [];
}

/// Default and opinionated window surface.
/// It is just a black surface with a white border going around it.
/// Not expected to be used in a proper window manager but exists only to have something
/// rather than no surface by default.
class DefaultWindowBackground extends StatelessWidget {
  const DefaultWindowBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ShadowOccluder extends SingleChildRenderObjectWidget {
  final double elevation;
  final ShapeBorder shape;

  const _ShadowOccluder({
    required Widget child,
    this.elevation = 0,
    this.shape = const RoundedRectangleBorder(),
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ShadowOccluderRenderBox(
      elevation: elevation,
      shape: shape,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _ShadowOccluderRenderBox renderObject,
  ) {
    renderObject
      ..elevation = elevation
      ..shape = shape;
  }
}

class _ShadowOccluderRenderBox extends RenderProxyBox {
  double get elevation => _elevation;
  double _elevation;
  set elevation(double value) {
    if (value == _elevation) {
      return;
    }
    _elevation = value;
    markNeedsPaint();
  }

  ShapeBorder get shape => _shape;
  ShapeBorder _shape;
  set shape(ShapeBorder value) {
    if (value == _shape) {
      return;
    }
    _shape = value;
    markNeedsPaint();
  }

  _ShadowOccluderRenderBox({
    double elevation = 0,
    ShapeBorder shape = const RoundedRectangleBorder(),
  })  : _elevation = elevation,
        _shape = shape;

  @override
  void paint(PaintingContext context, Offset position) {
    final _baseRect = position & size;
    final _shapePath = shape.getOuterPath(_baseRect);

    context.canvas.save();
    context.canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(_baseRect.inflate(256)),
        _shapePath,
      ),
    );
    context.canvas.drawShadow(_shapePath, Colors.black, elevation, true);
    context.canvas.restore();
    context.paintChild(child!, position);
  }
}
