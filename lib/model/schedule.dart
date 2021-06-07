class Schedule {
  final String title;
  final String titleDate;
  final DateTime date;
  final String imageUrl;
  final List<ScheduleEvent> events;

  Schedule({
    required this.title,
    required this.titleDate,
    required this.date,
    required this.imageUrl,
    required this.events,
  });
}

class ScheduleEvent {
  final String title;
  final List<ScheduleEventItem> items;

  ScheduleEvent({required this.title, required this.items});
}

class ScheduleEventItem {
  final String title;
  final String date;

  ScheduleEventItem({required this.title, required this.date});
}