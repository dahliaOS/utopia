import 'package:flutter/material.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/hierarchy.dart';
import 'package:utopia_wm/src/registry.dart';

class ToolbarWindowFeature extends WindowFeature {
  static const WindowPropertyKey<double> size =
      WindowPropertyKey('feature.toolbar.size', 24);
  static const WindowPropertyKey<Widget> widget =
      WindowPropertyKey('feature.toolbar.widget', DefaultToolbar());

  const ToolbarWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);

    return Column(
      children: [
        SizedBox(
          height: properties.toolbar.size,
          child: properties.toolbar.widget,
        ),
        Expanded(child: content),
      ],
    );
  }

  @override
  List<WindowPropertyKey> get requiredProperties => [];
}

class DefaultToolbar extends StatelessWidget {
  const DefaultToolbar();

  @override
  Widget build(BuildContext context) {
    final WindowPropertyRegistry properties =
        WindowPropertyRegistry.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        /* SizedBox(width: 4),
                        properties.icon != null
                            ? Image(
                                image: properties.icon!,
                                width: 16,
                                height: 16,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.settings,
                                size: 16,
                                color: Colors.white,
                              ), */
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            properties.info.title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontFamily: 'Ubuntu Mono',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      properties.geometry.position += details.delta;
                    },
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: SizedBox.fromSize(
                size: Size.square(properties.toolbar.size),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: ShapeDecoration(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: SizedBox.fromSize(
                size: Size.square(properties.toolbar.size),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                WindowHierarchy.of(context, listen: false)
                    .removeWindowEntry(properties.info.id);
              },
              child: SizedBox.fromSize(
                size: Size.square(properties.toolbar.size),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
