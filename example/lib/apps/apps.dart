import 'dart:ui';

import 'package:example/apps/calculator/calculator.dart';
import 'package:example/apps/entry.dart';
import 'package:example/apps/example/example.dart';
import 'package:utopia_wm/wm.dart';

const List<ApplicationEntry> applications = [
  ApplicationEntry(
    id: 'example',
    name: "Example app",
    description: "Just a simple app to drag around and play with",
    entryPoint: ExampleApp(),
  ),
  ApplicationEntry(
    id: 'calculator',
    name: "Calculator",
    description: "Mash those numbers and pray they actually work",
    entryPoint: Calculator(),
    overrideProperties: {
      ResizeWindowFeature.minSize: Size(640, 480),
    },
    overrideLayout: _calculatorLayout,
  ),
];

LayoutInfo _calculatorLayout(LayoutInfo info) =>
    info.copyWith(size: const Size(640, 480));
