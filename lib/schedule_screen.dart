import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sa_stateless_animation/sa_stateless_animation.dart';
import 'package:f1n/f1n_client.dart';

class ScheduleScreen extends StatefulWidget {
  final F1nResponse response;

  const ScheduleScreen({
    Key key,
    @required this.response,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen>
  with AutomaticKeepAliveClientMixin<ScheduleScreen> {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        PlayAnimation<double>(
          tween: Tween(
            begin: size.width,
            end: 0,
          ),
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 400),
          builder: (_, child, value) => Transform.translate(
            offset: Offset(value, 0),
            child: child,
          ),
          child: _buildImage(context),
        ),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: ScheduleTimerWidget(
            dateTime: widget.response.schedule.date,
          ),
        ),
        SizedBox(height: 16),
        PlayAnimation<double>(
          tween: Tween(
            begin: size.height * 0.7,
            end: 0,
          ),
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 400),
          builder: (_, child, value) => Transform.translate(
            offset: Offset(0, value),
            child: child,
          ),
          child: Column(
            children: _buildSchedule(),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: widget.response.schedule.imageUrl,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset.centerLeft,
                end: FractionalOffset.centerRight,
                colors: [
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  widget.response.schedule.title.toUpperCase(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.response.schedule.titleDate,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSchedule() {
    final List<Widget> result = [];
    for (final event in widget.response.schedule.events) {
      result.add(Text(
        event.title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ));
      for (final eventItem in event.items) {
        result.add(Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(eventItem.title),
              Text(eventItem.date),
            ],
          ),
        ));
      }
    }
    return result;
  }

  @override
  bool get wantKeepAlive => true;
}

class ScheduleTimerWidget extends StatefulWidget {
  final DateTime dateTime;

  const ScheduleTimerWidget({
    Key key,
    @required this.dateTime,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScheduleTimerWidgetState();
}

class ScheduleTimerWidgetState extends State<ScheduleTimerWidget> {
  Timer timer;
  String time;

  @override
  void initState() {
    super.initState();
    time = _getTime(widget.dateTime);
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          time = _getTime(widget.dateTime);
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).accentColor;
    return Row(
      children: <Widget>[
        Icon(
          Icons.timer,
          color: color,
        ),
        SizedBox(width: 16),
        Text(
          time,
          style: TextStyle(
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getTime(DateTime date) {
    int days = 0;
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    if (date.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
      final diff = date.difference(DateTime.now());
      days = diff.inDays;
      hours = diff.inHours - days * 24;
      minutes = diff.inMinutes - (days * 24 * 60 + hours * 60);
      seconds = diff.inSeconds -
          (days * 24 * 60 * 60 + hours * 60 * 60 + minutes * 60);
    }
    return 'До старта: $daysд $hoursч $minutesм $secondsс';
  }
}
