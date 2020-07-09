import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1n/model/schedule.dart';
import 'package:f1n/ui/store/main_store.dart';
import 'package:f1n/ui/widget/schedule_timer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('build ScheduleScreen');
    final schedule =
        Provider.of<MainStore>(context, listen: false).f1nFuture.value.schedule;
    return Column(
      children: <Widget>[
        _buildImage(context, schedule),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: ScheduleTimerWidget(
            dateTime: schedule.date,
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: _buildSchedule(schedule),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context, Schedule schedule) {
    return Stack(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: schedule.imageUrl,
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
                  schedule.title.toUpperCase(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  schedule.titleDate,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSchedule(Schedule schedule) {
    final List<Widget> result = [];
    for (final event in schedule.events) {
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
}
