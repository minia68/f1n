import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

class ScheduleTimerWidget extends StatefulWidget {
  final DateTime dateTime;

  const ScheduleTimerWidget({
    Key? key,
    required this.dateTime,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScheduleTimerWidgetState();
}

class ScheduleTimerWidgetState extends State<ScheduleTimerWidget> {
  Timer? timer;
  String? time;

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
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Row(
      children: <Widget>[
        Icon(
          Icons.timer,
          color: color,
        ),
        SizedBox(width: 16),
        Text(
          time ?? '',
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
    final now = clock.now();
    if (date.millisecondsSinceEpoch > now.millisecondsSinceEpoch) {
      final diff = date.difference(now);
      days = diff.inDays;
      hours = diff.inHours - days * 24;
      minutes = diff.inMinutes - (days * 24 * 60 + hours * 60);
      seconds = diff.inSeconds -
          (days * 24 * 60 * 60 + hours * 60 * 60 + minutes * 60);
    }
    return 'До старта: $daysд $hoursч $minutesм $secondsс';
  }
}