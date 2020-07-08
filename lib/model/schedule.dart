class Schedule {
  final String title;
  final String titleDate;
  final DateTime date;
  final String imageUrl;
  final List<ScheduleEvent> events;

  Schedule({
    this.title,
    this.titleDate,
    this.date,
    this.imageUrl,
    this.events,
  });
}

class ScheduleEvent {
  final String title;
  final List<ScheduleEventItem> items;

  ScheduleEvent({this.title, this.items});
}

class ScheduleEventItem {
  final String title;
  final String date;

  ScheduleEventItem({this.title, this.date});
}