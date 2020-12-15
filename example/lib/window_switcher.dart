import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm.dart';

class WindowSwitcher extends StatefulWidget {
  final BuildContext context;
  final List<WindowEntry> windows;
  final List<WindowEntryId> windowFocus;
  final void Function(WindowEntry)? onFocusChange;

  WindowSwitcher({
    required this.context,
    required this.windows,
    required this.windowFocus,
    this.onFocusChange,
  });

  @override
  _WindowSwitcherState createState() => _WindowSwitcherState();
}

class _WindowSwitcherState extends State<WindowSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 200,
          maxWidth: MediaQuery.of(context).size.width - 360,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: Container(
              color: Colors.white.withOpacity(0.5),
              padding: EdgeInsets.all(8),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: widget.windows
                    .map(
                      (e) => SizedBox(
                        width: 240,
                        child: WindowPreview(
                          context: widget.context,
                          entry: e,
                          selected: widget.windowFocus.last == e.id,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WindowPreview extends StatelessWidget {
  final BuildContext context;
  final WindowEntry entry;
  final bool selected;

  WindowPreview({
    required this.context,
    required this.entry,
    this.selected = false,
  });

  @override
  Widget build(BuildContext _context) {
    final hierarchy = context.read<WindowHierarchyState>();

    return Container(
      height: 168,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: selected ? Colors.black38 : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  SizedBox(width: 8),
                  if (entry.icon != null)
                    Image(
                      image: entry.icon!,
                      width: 16,
                      height: 16,
                    ),
                  if (entry.icon != null) SizedBox(width: 4),
                  Text(entry.title ?? ""),
                  Spacer(),
                  SizedBox.fromSize(
                    size: Size.square(32),
                    child: InkWell(
                      onTap: () {
                        hierarchy.popWindowEntry(entry);
                      },
                      customBorder: CircleBorder(),
                      child: Icon(Icons.close),
                      hoverColor: Colors.red,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: IgnorePointer(
                child: Card(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: FutureBuilder<Uint8List>(
                    future: entry.getScreenshot(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      } else {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        );
                      }
                    },
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
