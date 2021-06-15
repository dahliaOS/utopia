import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class WindowResizeGestureDetector extends StatelessWidget {
  final double? borderThickness;
  final Map<Alignment, GestureDragUpdateCallback> listeners;
  final GestureDragEndCallback? onPanEnd;

  WindowResizeGestureDetector({
    this.borderThickness,
    required this.listeners,
    this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners[Alignment.topLeft],
              SystemMouseCursors.resizeUpLeft,
            ),
            Expanded(
              child: buildGestureDetector(
                null,
                borderThickness,
                listeners[Alignment.topCenter],
                SystemMouseCursors.resizeUp,
              ),
            ),
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners[Alignment.topRight],
              SystemMouseCursors.resizeUpRight,
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              buildGestureDetector(
                borderThickness,
                null,
                listeners[Alignment.centerLeft],
                SystemMouseCursors.resizeLeft,
              ),
              Spacer(),
              buildGestureDetector(
                borderThickness,
                null,
                listeners[Alignment.centerRight],
                SystemMouseCursors.resizeRight,
              ),
            ],
          ),
        ),
        Row(
          children: [
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners[Alignment.bottomLeft],
              SystemMouseCursors.resizeDownLeft,
            ),
            Expanded(
              child: buildGestureDetector(
                null,
                borderThickness,
                listeners[Alignment.bottomCenter],
                SystemMouseCursors.resizeDown,
              ),
            ),
            buildGestureDetector(
              borderThickness,
              borderThickness,
              listeners[Alignment.bottomRight],
              SystemMouseCursors.resizeDownRight,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildGestureDetector(
    double? width,
    double? height,
    GestureDragUpdateCallback? onPanUpdate,
    SystemMouseCursor cursor,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
        ),
      ),
    );
  }
}
