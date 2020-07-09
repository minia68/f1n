import 'package:clock/clock.dart';
import 'package:f1n/ui/widget/schedule_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ScheduleTimerWidget test', (WidgetTester tester) async {
    final dateTime = DateTime(2020, 1, 3, 4, 5);
    int pumpCount = 0;
    withClock(Clock(() {
      if (pumpCount == 0) {
        return DateTime(2020, 1, 2, 2, 2);
      } else if (pumpCount == 1) {
        return DateTime(2020, 1, 2, 2, 2, 1);
      } else if (pumpCount == 2) {
        return DateTime(2020, 1, 2, 3, 6);
      } else {
        return DateTime(2020, 1, 2, 5, 5);
      }
    }), () async {
      await tester.pumpWidget(MaterialApp(home: ScheduleTimerWidget(dateTime: dateTime)));
      expect(find.text('До старта: 1д 2ч 3м 0с'), findsOneWidget);

      pumpCount++;
      await tester.pump(Duration(seconds: 1));
      expect(find.text('До старта: 1д 2ч 2м 59с'), findsOneWidget);

      pumpCount++;
      await tester.pump(Duration(seconds: 1));
      expect(find.text('До старта: 1д 0ч 59м 0с'), findsOneWidget);

      pumpCount++;
      await tester.pump(Duration(seconds: 1));
      expect(find.text('До старта: 0д 23ч 0м 0с'), findsOneWidget);
    });
  });
}

//class TestF1nProvider implements F1nProvider {
//  @override
//  Future<ArticleDetail> getArticle(String url) async {
//    await Future.delayed(Duration(seconds: 1));
//    if (url == 'mainTitle1' || url == 'latestTitle1') {
//      return ArticleDetail(
//        title: 'title1',
//        date: 'date1',
//        text: 'text1',
//        imageUrl: null,
//      );
//    } else {
//      return ArticleDetail(
//        title: 'title2',
//        date: 'date2',
//        text: 'text2',
//        imageUrl: 'https://cdn.f1ne.ws/userfiles/wolff/143034.jpg',
//      );
//    }
//  }
//
//  @override
//  Future<F1nHome> getHomePage() async {
//    await Future.delayed(Duration(seconds: 1));
//    return F1nHome(
//      main: [
//        Article(
//          title: 'mainTitle1',
//          date: '',
//          detailUrl: 'mainDetailUrl1',
//          imageUrl: 'https://cdn.f1ne.ws/userfiles/marko/145212.jpg',
//        ),
//        Article(
//          title: 'mainTitle2',
//          date: '',
//          detailUrl: 'mainDetailUrl2',
//          imageUrl: 'https://cdn.f1ne.ws/userfiles/wolff/143034.jpg',
//        ),
//      ],
//      latest: [
//        Article(
//          title: 'latestTitle1',
//          date: '10:53',
//          detailUrl: 'latestDetailUrl1',
//          imageUrl: 'https://cdn.f1ne.ws/userfiles/marko/145212.jpg',
//        ),
//        Article(
//          title: 'latestTitle2',
//          date: '08/07',
//          detailUrl: 'latestDetailUrl2',
//          imageUrl: null,
//        ),
//      ],
//      schedule: Schedule(
//        title: 'scheduleTitle',
//        date: DateTime(2020, 1, 2, 3, 4),
//        imageUrl:
//            'https://cdn.f1ne.ws/build/images/champ/2015/australia.14cb3d69.jpg',
//        titleDate: 'scheduleTitleDate',
//        events: [
//          ScheduleEvent(title: 'ScheduleEvent1Title', items: [
//            ScheduleEventItem(title: 'ScheduleEvent1Item1Title', date: ''),
//            ScheduleEventItem(title: 'ScheduleEvent1Item1Title', date: '13:41'),
//          ]),
//          ScheduleEvent(title: 'ScheduleEvent2Title', items: [
//            ScheduleEventItem(title: 'ScheduleEvent2Item1Title', date: '07:06'),
//            ScheduleEventItem(title: 'ScheduleEvent2Item2Title', date: '12:43'),
//          ]),
//        ],
//      ),
//    );
//  }
//}
