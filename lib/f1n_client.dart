import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class F1nClient {
  final Dio dio;

  F1nClient(this.dio);

  Future<F1nResponse> getMainPage() async {
    try {
      final response = await dio.get<String>(
        'https://www.f1news.ru/',
        options: RequestOptions(
          responseType: ResponseType.plain,
          queryParameters: {},
        ),
      );
      final doc = parse(response.data);
      final List<Article> main = [];

      final superNews = doc.querySelector('.b-home__wrap .b-home-super-news');
      final superNewsArticle = Article(
        imageUrl: superNews
            .querySelector('.b-home-super-news__image')
            .attributes['src'],
        detailUrl: superNews
            .querySelector('.b-home-super-news__link')
            .attributes['href'],
        title: superNews.querySelector('.b-home-super-news__title a').text,
        content: superNews.querySelector('.b-home-super-news__text').text,
      );
      main.add(superNewsArticle);

      final articles = doc.querySelectorAll('.b-home__features .article');
      for (final article in articles) {
        main.add(Article(
          imageUrl: _getArticleImageUrl(
              article.querySelector('.article_image img').attributes['src']),
          detailUrl:
              article.querySelector('.article_title a').attributes['href'],
          title: article.querySelector('.article_title a').text,
          content: article.querySelector('.article_content').text,
        ));
      }

      final List<Article> latest = [];
      final list = doc.querySelectorAll('.b-home__list .b-news-list__item');
      for (final listItem in list) {
        final imageUrl =
            listItem.querySelector('.b-news-list__img')?.attributes;
        latest.add(Article(
          imageUrl: imageUrl != null ? imageUrl['src'] : null,
          detailUrl:
              listItem.querySelector('.b-news-list__title').attributes['href'],
          title: listItem.querySelector('.b-news-list__title').text,
          content: listItem.querySelector('.b-news-list__date').text,
        ));
      }

      return F1nResponse(
        main: main,
        latest: latest,
        schedule: _getSchedule(doc),
      );
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  Schedule _getSchedule(Document doc) {
    final sidebar = doc.querySelector('.b-main__sidebar');
    final streamWrap = sidebar.querySelector('.stream_wrap');

    final title = streamWrap.querySelector('.stream_title').text;
    final date = streamWrap.querySelector('.stream_date').text;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(streamWrap
        .querySelector('.stream_countdown')
        .attributes['data-timestamp']) * 1000);
    final image = _getScheduleImageUrl(streamWrap.attributes['style']);

    final List<ScheduleEvent> scheduleEvents = [];
    final events =
        sidebar.querySelectorAll('.stream_list thead').skip(1).toList();
    for (final event in events) {
      final eventTitle = event.querySelector('.event-item-title').text;
      final List<ScheduleEventItem> items = [];
      final eventItems = event.nextElementSibling;
      for (final tr in eventItems.children) {
        items.add(ScheduleEventItem(
          title: tr.querySelector('.event-item').text,
          date: tr.querySelector('.event-time').text,
        ));
      }
      scheduleEvents.add(ScheduleEvent(
        title: eventTitle,
        items: items,
      ));
    }
    return Schedule(
      title: title,
      date: dateTime,
      titleDate: date,
      imageUrl: image,
      events: scheduleEvents,
    );
  }

  String _getScheduleImageUrl(String imageUrl) {
    final idx = imageUrl.indexOf('url(');
    return imageUrl.substring(idx + 4, imageUrl.length - 2);
  }

  Future<ArticleDetail> getArticle(String url) async {
    try {
      final response = await dio.get<String>(
        url,
        options: RequestOptions(
          responseType: ResponseType.plain,
          queryParameters: {},
        ),
      );
      final doc = parse(response.data);

      return ArticleDetail(
        title: doc.querySelector('.post_title').text,
        date: doc.querySelector('.post_info .post_date').text,
        imageUrl: doc.querySelector('.post_thumbnail img').attributes['src'],
        text:
            doc.querySelectorAll('.post_content p').map((e) => e.text).toList(),
      );
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  String _getArticleImageUrl(String imageUrl) {
    if (imageUrl == null) {
      return null;
    }
    final key = '/userfiles/';
    final idx = imageUrl.indexOf(key);
    return '//cdn.f1ne.ws${imageUrl.substring(idx, imageUrl.length)}';
  }
}

class Article {
  final String imageUrl;
  final String detailUrl;
  final String title;
  final String content;

  Article({String imageUrl, String detailUrl, this.title, this.content})
      : imageUrl = imageUrl != null ? 'https:$imageUrl' : null,
        detailUrl = detailUrl.startsWith('http')
            ? detailUrl
            : 'https://www.f1news.ru$detailUrl';
}

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

class F1nResponse {
  final List<Article> main;
  final List<Article> latest;
  final Schedule schedule;

  F1nResponse({
    this.main,
    this.latest,
    this.schedule,
  });
}

class ArticleDetail {
  final String title;
  final String imageUrl;
  final String date;
  final List<String> text;

  ArticleDetail({this.title, this.imageUrl, this.date, this.text});
}
