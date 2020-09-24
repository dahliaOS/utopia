import 'package:flutter/material.dart';

class WindowEntry {
  String title;
  final Widget content;

  WindowEntry({
    @required this.title,
    @required this.content,
  });

  @override
  String toString() {
    return {
      "title": this.title,
      "content": this.content,
      "hashCode": this.hashCode,
    }.toString();
  }
}
