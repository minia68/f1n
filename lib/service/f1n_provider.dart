import 'package:dio/dio.dart';
import 'package:f1n/model/article.dart';
import 'package:f1n/model/article_detail.dart';
import 'package:f1n/model/f1n_home.dart';
import 'package:f1n/model/schedule.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;

class F1nProvider {
  @visibleForOverriding
  static final homeUrl = 'https://www.f1news.ru';
  @visibleForOverriding
  static final rssUrl = 'https://www.f1news.ru/export/news.xml';

  final Dio dio;

  F1nProvider(this.dio);

  Future<F1nHome> getHomePage() async {
    try {
      final response = await dio.get<String>(
        homeUrl,
        options: RequestOptions(
          responseType: ResponseType.plain,
          queryParameters: {},
        ),
      );

      final doc = parse(response.data);
      final List<Article> main = [];
      main.add(_parseMainArticle(doc));
      _parseMainArticles(doc, main);

      final rssResponse = await dio.get<String>(
        rssUrl,
        options: RequestOptions(
          responseType: ResponseType.plain,
          queryParameters: {},
        ),
      );

      return F1nHome(
        main: main,
        latest: _parseRss(rssResponse.data),
        schedule: _getSchedule(doc),
      );
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
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
        date: doc.querySelector('.post_info .post_date')?.text ?? '',
        imageUrl: doc.querySelector('.post_thumbnail img').attributes['src'],
        text: doc.querySelector('.post_content').innerHtml.trim(),
      );
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  Article _parseMainArticle(Document doc) {
    final superNews = doc.querySelector('.b-home__wrap .b-home-super-news');
    return Article(
      imageUrl: _setImageUrl(superNews
          .querySelector('.b-home-super-news__image')
          .attributes['src']),
      detailUrl: _setDetailUrl(superNews
          .querySelector('.b-home-super-news__link')
          .attributes['href']),
      title: superNews.querySelector('.b-home-super-news__title a').text,
      date: '',
    );
  }

  void _parseMainArticles(Document doc, List<Article> main) {
    final articles = doc.querySelectorAll('.b-home__features .article');
    for (final article in articles) {
      main.add(Article(
        imageUrl: _setImageUrl(_getMainArticleImageUrl(
            article.querySelector('.article_image img').attributes['src'])),
        detailUrl: _setDetailUrl(
            article.querySelector('.article_title a').attributes['href']),
        title: article.querySelector('.article_title a').text,
        date: '',
      ));
    }
  }

//  List<Article> _parseArticles(Document doc) {
//    final List<Article> latest = [];
//    final list = doc.querySelectorAll('.b-home__list .b-news-list__item');
//    for (final listItem in list) {
//      final imageUrl = listItem.querySelector('.b-news-list__img')?.attributes;
//      latest.add(Article(
//        imageUrl: imageUrl != null ? _setImageUrl(imageUrl['src']) : null,
//        detailUrl: _setDetailUrl(
//            listItem.querySelector('.b-news-list__title').attributes['href']),
//        title: listItem.querySelector('.b-news-list__title').text,
//        date: listItem.querySelector('.b-news-list__date').text,
//      ));
//    }
//    return latest;
//  }

  List<Article> _parseRss(String data) {
    final result = <Article>[];
    final document = xml.parse(data);
    final items = document.findAllElements('item');
    for (final item in items) {
      final pubDate = item.findElements('pubDate').single.text.trim();
      final startIdx = pubDate.indexOf(':') - 2;
      result.add(Article(
        title: item.findElements('title').single.text.trim(),
        imageUrl:
            item.findElements('enclosure').single.getAttribute('url').trim(),
        detailUrl: item.findElements('link').single.text.trim(),
        date: pubDate.substring(
            startIdx, startIdx + 5), //TODO implement today time others dd.MM
      ));
    }
    return result;
  }

  Schedule _getSchedule(Document doc) {
    final sidebar = doc.querySelector('.b-main__sidebar');
    final streamWrap = sidebar.querySelector('.stream_wrap');

    final title = streamWrap.querySelector('.stream_title').text;
    final date = streamWrap.querySelector('.stream_date').text;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(streamWrap
            .querySelector('.stream_countdown')
            .attributes['data-timestamp']) *
        1000);
    final image = _getScheduleImageUrl(streamWrap.attributes['style']);

    final List<ScheduleEvent> scheduleEvents = [];
    final events =
        sidebar.querySelectorAll('.stream_list thead').skip(1).toList();
    for (final event in events) {
      final eventTitle = event.querySelector('.event-item-title').text.trim();
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

  String _setImageUrl(String imageUrl) {
    if (imageUrl == null) {
      return null;
    }
    return imageUrl.startsWith('http') ? imageUrl : 'https:$imageUrl';
  }

  String _setDetailUrl(String detailUrl) {
    return detailUrl.startsWith('http') ? detailUrl : '$homeUrl$detailUrl';
  }

  String _getMainArticleImageUrl(String imageUrl) {
    if (imageUrl == null) {
      return null;
    }
    final key = '/userfiles/';
    final idx = imageUrl.indexOf(key);
    return '//cdn.f1ne.ws${imageUrl.substring(idx, imageUrl.length)}';
  }
}
