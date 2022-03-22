import 'package:flutter/widgets.dart';
import 'package:utopia_wm/wm.dart';

abstract class WindowFeature {
  const WindowFeature();

  Widget build(BuildContext context, Widget content);

  List<WindowPropertyKey> get requiredProperties;
}
