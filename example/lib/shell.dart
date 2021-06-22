import 'package:example/components/launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/wm_new.dart';

import 'components/taskbar.dart';

class ShellDirector extends StatefulWidget {
  const ShellDirector({Key? key}) : super(key: key);

  @override
  State<ShellDirector> createState() => ShellDirectorState();
}

class ShellDirectorState extends State<ShellDirector> {
  bool _showLauncher = false;

  bool get showLauncher => _showLauncher;
  set showLauncher(bool value) {
    _showLauncher = value;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      WindowHierarchy.of(context, listen: false).wmInsets =
          const EdgeInsets.only(bottom: 25);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Listener(
                onPointerDown: (event) {
                  showLauncher = false;
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Taskbar(
              controller: WindowHierarchy.of(context),
            ),
            Positioned(
              bottom: 25,
              left: 0,
              width: 320,
              child: Offstage(
                offstage: !_showLauncher,
                child: const Launcher(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
