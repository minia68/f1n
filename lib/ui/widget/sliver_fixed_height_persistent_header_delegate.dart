import 'package:flutter/material.dart';

class SliverFixedHeightPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  SliverFixedHeightPersistentHeaderDelegate({
    required Widget child,
    required double height,
  }) : _child = child, _extent = height;

  final Widget _child;
  final _extent;

  @override
  double get minExtent => _extent;
  @override
  double get maxExtent => _extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: _child,
      color: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  bool shouldRebuild(SliverFixedHeightPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
