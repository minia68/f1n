import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1n/model/f1n_home.dart';
import 'package:f1n/ui/schedule_timer.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  final F1nHome response;

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
    return Column(
      children: <Widget>[
        _buildImage(context),
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
        Column(
          children: _buildSchedule(),
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


