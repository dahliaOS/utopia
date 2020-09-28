import 'package:flutter/material.dart';

class WallpaperLayer extends StatefulWidget {
  @override
  _WallpaperLayerState createState() => _WallpaperLayerState();
}

class _WallpaperLayerState extends State<WallpaperLayer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.network(
        "https://i.imgur.com/BHPUd0d.jpg",
        fit: BoxFit.cover,
      ),
    );
  }
}
