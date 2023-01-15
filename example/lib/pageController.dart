import 'dart:math';

import 'package:flutter/widgets.dart';

class AdvancedPageController extends PageController {
  AdvancedPageController({
    int initialPage = 0,
    double initialViewportFraction = 1.0,
  }) : _viewportFraction = initialViewportFraction, super(initialPage: initialPage);

  double? _viewportFraction;
  @override
  double get viewportFraction => _viewportFraction ?? super.viewportFraction;
  set viewportFraction(double value) => _viewportFraction = value;
}