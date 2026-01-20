import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tiny_square/presentation/consts/homepage_contants.dart';

/// A builder that provides an infinitely repeating progress value from 0.0 to 1.0.
/// Includes a delayed stop mechanism when [isActive] becomes false.
class InfiniteProgressBuilder extends StatefulWidget {
  const InfiniteProgressBuilder({
    super.key,
    required this.duration,
    required this.builder,
    this.isActive = true,
    this.stopDelay = HomepageConstants.loadingBorderStopDelay,
  });

  final Duration duration;
  final Duration stopDelay;
  final bool isActive;
  final Widget Function(BuildContext context, double progress) builder;

  @override
  State<InfiniteProgressBuilder> createState() => _InfiniteProgressBuilderState();
}

class _InfiniteProgressBuilderState extends State<InfiniteProgressBuilder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(InfiniteProgressBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive) {
      _stopTimer?.cancel();
      _stopTimer = null;

      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else if (!widget.isActive && _controller.isAnimating) {
      _stopTimer?.cancel();
      _stopTimer = Timer(widget.stopDelay, () {
        if (mounted && !widget.isActive) {
          _controller.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (context, _) => widget.builder(context, _controller.value));
  }
}
