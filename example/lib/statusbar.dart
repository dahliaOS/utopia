import 'dart:ui';

import 'package:flutter/material.dart';

class Statusbar extends StatefulWidget {
  @override
  _StatusbarState createState() => _StatusbarState();
}

class _StatusbarState extends State<Statusbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;

  @override
  void initState() {
    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Animation<Alignment> clockAlignAnim = AlignmentTween(
      begin: Alignment.topCenter,
      end: Alignment.topLeft,
    ).animate(_ac);

    Animation<TextStyle> clockTextAnim = TextStyleTween(
      begin: TextStyle(
        fontSize: 16,
        color: Colors.grey[900],
        fontWeight: FontWeight.w400,
      ),
      end: TextStyle(
        fontSize: 28,
        color: Colors.grey[900],
        fontWeight: FontWeight.w600,
      ),
    ).animate(_ac);

    Animation<EdgeInsets> clockInsetsAnim = EdgeInsetsTween(
      begin: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 8,
      ),
      end: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
    ).animate(_ac);

    Animation<EdgeInsets> iconsInsetsAnim = EdgeInsetsTween(
      begin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      end: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 24,
      ),
    ).animate(_ac);

    return AnimatedBuilder(
      animation: _ac,
      builder: (context, _) {
        return Stack(
          children: [
            IgnorePointer(
              ignoring: _ac.value <= 0.5,
              child: GestureDetector(
                onTap: () => _ac.fling(velocity: -1),
                child: Container(
                  color: Colors.black.withOpacity(_ac.value * 0.4),
                ),
              ),
            ),
            Positioned(
              top: (_ac.value * (MediaQuery.of(context).size.height - 24)) -
                  (MediaQuery.of(context).size.height - 24),
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 24,
                    sigmaY: 24,
                  ),
                  child: GestureDetector(
                    onVerticalDragUpdate: _update,
                    onVerticalDragEnd: _end,
                    child: Material(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Padding(
                padding: clockInsetsAnim.value,
                child: Align(
                  alignment: clockAlignAnim.value,
                  child: Text(
                    "12:00",
                    style: clockTextAnim.value,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: iconsInsetsAnim.value,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: Colors.grey[900],
                      size: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.signal_wifi_4_bar_outlined),
                        Icon(Icons.signal_cellular_null),
                        Icon(Icons.battery_charging_full),
                        SizedBox(
                          height: 16,
                          child: SizeTransition(
                            sizeFactor: _ac,
                            axis: Axis.horizontal,
                            axisAlignment: -1,
                            child: Text(
                              "80%",
                              textHeightBehavior: TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: true,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                height: 16,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20.0 + 16.0,
              right: 24,
              child: Visibility(
                visible: _ac.value > 0.01,
                child: Opacity(
                  opacity: _ac.value,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(_ac),
                    child: Text(
                      "1 January 2021",
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: (_ac.value * (MediaQuery.of(context).size.height - 24)),
              child: Opacity(
                opacity: _ac.value,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 24,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 4,
                      width: 56,
                      decoration: ShapeDecoration(
                        shape: StadiumBorder(),
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _update(DragUpdateDetails details) {
    _ac.value +=
        details.primaryDelta! / (MediaQuery.of(context).size.height - 24);
  }

  void _end(DragEndDetails details) {
    if (details.primaryVelocity!.abs() > 365) {
      if (_ac.status == AnimationStatus.forward) {
        _ac.fling(velocity: -1);
      } else {
        _ac.fling(velocity: 1);
      }

      return;
    }

    if (_ac.value > 0.5) {
      _ac.fling(velocity: 1);
    } else {
      _ac.fling(velocity: -1);
    }
  }
}
