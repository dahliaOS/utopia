import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/registry.dart';

class SurfaceWindowFeature extends WindowFeature {
  static const WindowPropertyKey<ShapeBorder> shape =
      WindowPropertyKey('feature.surface.shape', RoundedRectangleBorder());
  static const WindowPropertyKey<Widget> background = WindowPropertyKey(
      'feature.surface.background', DefaultWindowBackground());
  static const WindowPropertyKey<double> elevation =
      WindowPropertyKey('feature.surface.elevation', 0);

  const SurfaceWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);

    return _ShadowOccluder(
      shape: properties.geometry.maximized
          ? const RoundedRectangleBorder()
          : properties.surface.shape,
      elevation: properties.surface.elevation,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: properties.surface.shape),
        clipBehavior: Clip.antiAlias,
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

class DefaultWindowBackground extends StatelessWidget {
  const DefaultWindowBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          width: 1,
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
      BuildContext context, _ShadowOccluderRenderBox renderObject) {
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
    context.canvas.clipPath(Path.combine(
      PathOperation.difference,
      Path()..addRect(_baseRect.inflate(256)),
      _shapePath,
    ));
    context.canvas.drawShadow(_shapePath, Colors.black, elevation, true);
    context.canvas.restore();
    context.paintChild(child!, position);
  }
}
