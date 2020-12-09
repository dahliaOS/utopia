import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/dismissible_overlay_entry.dart';

class DismissibleOverlay extends StatefulWidget {
  final DismissibleOverlayEntry entry;

  DismissibleOverlay({
    Key key,
    @required this.entry,
  }) : super(key: key);

  @override
  _DismissibleOverlayState createState() => _DismissibleOverlayState();
}

class _DismissibleOverlayState extends State<DismissibleOverlay>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    widget.entry.animationController = AnimationController(
      vsync: this,
      duration: widget.entry.duration,
    );
    widget.entry.animation = CurvedAnimation(
      curve: widget.entry.curve,
      reverseCurve: widget.entry.reverseCurve,
      parent: widget.entry.animationController,
    );
    widget.entry.animationController.animateTo(1);

    super.initState();
  }

  void dispose() {
    widget.entry.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DismissibleOverlayEntry>.value(
      value: widget.entry,
      builder: (context, _) {
        final entry = context.watch<DismissibleOverlayEntry>();

        return Stack(
          children: [
            IgnorePointer(
              child: SizedBox.expand(
                child: entry.background ?? Container(color: Colors.transparent),
              ),
            ),
            entry.content,
          ],
        );
      },
    );
  }
}
