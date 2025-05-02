import 'package:flutter/widgets.dart';

class SlowMaxScrollPhysics extends ScrollPhysics {
  final double maxOffset;

  const SlowMaxScrollPhysics({required this.maxOffset, super.parent});

  @override
  SlowMaxScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowMaxScrollPhysics(
      maxOffset: maxOffset,
      parent: buildParent(ancestor),
    );
  }

  // Limit max scroll offset
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value > maxOffset) {
      return value - maxOffset;
    }
    return super.applyBoundaryConditions(position, value);
  }

  // Slow down the user drag scroll speed
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * 0.3; // Adjust this multiplier to control speed
  }
}
