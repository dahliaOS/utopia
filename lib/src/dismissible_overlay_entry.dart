import 'package:flutter/material.dart';

class DismissibleOverlayEntry extends ChangeNotifier {
  final String uniqueId;
  final Widget content;
  final Widget? background;
  final Key? key;
  final DismissibleOverlayEntryId id;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  late AnimationController animationController;
  late Animation animation;
  bool _enableDismiss;

  bool get enableDismiss => _enableDismiss;

  set enableDismiss(bool value) {
    _enableDismiss = value;
    notifyListeners();
  }

  DismissibleOverlayEntry({
    required this.uniqueId,
    required this.content,
    this.background,
    this.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    this.reverseCurve = Curves.linear,
    bool enableDismiss = true,
  })  : id = DismissibleOverlayEntryId(),
        _enableDismiss = enableDismiss;
}

class DismissibleOverlayEntryId {
  int compareTo(DismissibleOverlayEntryId other) {
    return this.hashCode.compareTo(other.hashCode);
  }

  @override
  String toString() => hashCode.toString();
}
