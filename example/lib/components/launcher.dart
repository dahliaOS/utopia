import 'package:example/calculator.dart';
import 'package:example/shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm.dart';

class Launcher extends StatelessWidget {
  static const entry = WindowEntry(
    features: [
      ResizeWindowFeature(),
      ShadowWindowFeature(),
      FocusableWindowFeature(),
      SurfaceWindowFeature(),
      ToolbarWindowFeature(),
      PaddedContentWindowFeature(),
    ],
    layoutInfo: FreeformLayoutInfo(
      size: Size(400, 300),
      position: Offset.zero,
    ),
    properties: {
      WindowEntry.title: "Calculator",
      WindowEntry.icon: null,
      ResizeWindowFeature.minSize: Size(320, 240),
      ResizeWindowFeature.maxSize: Size.infinite,
    },
  );

  const Launcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: Offset(1, -1),
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(1, 0),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Material(
              type: MaterialType.transparency,
              child: SizedBox(
                height: 360,
                width: double.infinity,
                child: ListView.builder(
                  itemBuilder: (context, index) => getAppLauncher(context),
                  itemCount: 8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.power_settings_new, size: 16),
                    label: const Text('Shutdown'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.restart_alt, size: 16),
                    label: const Text('Restart'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppLauncher(BuildContext context) {
    return ListTile(
      leading: const FlutterLogo(size: 24),
      title: const Text("Calculator"),
      subtitle: const Text(
        "dahliaOS calculator",
      ),
      onTap: () {
        WindowHierarchy.of(
          context,
          listen: false,
        ).addWindowEntry(entry.newInstance(
          content: Calculator(),
          //eventHandler: LogWindowEventHandler(),
        ));

        Provider.of<ShellDirectorState>(
          context,
          listen: false,
        ).showLauncher = false;
      },
    );
  }
}

class ShadowWindowFeature extends WindowFeature {
  const ShadowWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            spreadRadius: 2,
          ),
        ],
      ),
      child: content,
    );
  }
}

class PaddedContentWindowFeature extends WindowFeature {
  const PaddedContentWindowFeature();

  @override
  Widget build(BuildContext context, Widget content) {
    final LayoutState layout = LayoutState.of(context);

    if (layout.fullscreen) return content;

    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 1, 1),
      child: content,
    );
  }
}

class LogWindowEventHandler extends WindowEventHandler {
  @override
  void onEvent(WindowEvent event) {
    print(event);
    super.onEvent(event);
  }
}
