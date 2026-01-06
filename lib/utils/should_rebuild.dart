library;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

typedef ShouldRebuildFunction<T> = bool Function(T oldWidget, T newWidget);

class ShouldBeRebuild<T extends Widget> extends StatefulWidget {
  final Widget child;
  final ShouldRebuildFunction<T>? shouldRebuild;

  ShouldBeRebuild({super.key, required this.child, required this.shouldRebuild})
      : assert(() {
          return true;
        }());

  @override
  _ShouldRebuildState createState() => _ShouldRebuildState<T>();
}

class _ShouldRebuildState<T extends Widget> extends State<ShouldBeRebuild> {
  late Widget oldWidget;

  @override
  Widget build(BuildContext context) {
    final Widget newWidget = widget.child;
    if (widget.shouldRebuild!(oldWidget, newWidget)) {
      this.oldWidget = newWidget;
    }
    return oldWidget;
  }
}
