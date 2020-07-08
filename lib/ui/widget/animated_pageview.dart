import 'package:flutter/material.dart';
import 'package:sa_stateless_animation/sa_stateless_animation.dart';

class AnimatedPageView extends StatefulWidget {
  final int itemCount;
  final Widget Function(int) itemBuilder;

  const AnimatedPageView({
    Key key,
    @required this.itemCount,
    @required this.itemBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedPageViewState();
}

class _AnimatedPageViewState extends State<AnimatedPageView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return PlayAnimation<double>(
      tween: Tween(
        begin: MediaQuery.of(context).size.width,
        end: 0,
      ),
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 200),
      builder: (_, child, value) => Transform.translate(
        offset: Offset(value, 0),
        child: child,
      ),
      child: _buildMain(),
    );
  }

  Widget _buildMain() {
    return PageView.builder(
      controller: PageController(
        viewportFraction: 0.85,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (_, i) => AnimatedPadding(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(_index == i ? 0 : 12.0),
        child: widget.itemBuilder(i),
      ),
      onPageChanged: (int index) => setState(() {
        _index = index;
      }),
    );
  }
}
