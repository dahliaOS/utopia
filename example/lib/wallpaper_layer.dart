import 'package:flutter/material.dart';

class WallpaperLayer extends StatefulWidget {
  final ImageProvider image;

  WallpaperLayer({
    required this.image,
  });

  @override
  _WallpaperLayerState createState() => _WallpaperLayerState();
}

class _WallpaperLayerState extends State<WallpaperLayer> {
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 700),
      child: SizedBox.expand(
        key: ValueKey(widget.image),
        child: Image(
          image: widget.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
