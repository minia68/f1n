import 'dart:io';

import 'package:dio/dio.dart';
import 'package:f1n/model/article.dart';
import 'package:f1n/model/schedule.dart';
import 'package:f1n/service/f1n_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  test('getHomePage test', () async {
    final dio = MockDio();
    when(dio.get<String>(
      F1nProvider.homeUrl,
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
          statusCode: 200,
          data: File('test/assets/f1n_home.html').readAsStringSync(),
        ));
    when(dio.get<String>(
      F1nProvider.rssUrl,
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
          statusCode: 200,
          data: File('test/assets/f1n_news.xml').readAsStringSync(),
        ));

    final f1nHome = await F1nProvider(dio).getHomePage();
    expect(f1nHome.main.length, 7);
    Article article = f1nHome.main[0];
    expect(article.title, 'В Renault объявили о возвращении Фернандо Алонсо');
    expect(article.date, '');
    expect(article.imageUrl, 'https://cdn.f1ne.ws/userfiles/alonso/145514_sm.jpg');
    expect(article.detailUrl, 'https://www.f1news.ru/news/f1-145514.html');

    article = f1nHome.main[1];
    expect(article.title, 'Гран При Штирии: Превью этапа');
    expect(article.date, '');
    expect(article.imageUrl, 'https://cdn.f1ne.ws/userfiles/145140.jpg');
    expect(article.detailUrl,
        'http://www.f1news.ru/Championship/2020/styria/preview.shtml');

    article = f1nHome.main[6];
    expect(article.title, 'Эстебан Окон: На следующей неделе всё изменится');
    expect(article.date, '');
    expect(article.imageUrl, 'https://cdn.f1ne.ws/userfiles/145465.jpg');
    expect(
        article.detailUrl, 'http://www.f1news.ru/interview/ocon/145465.shtml');

    expect(f1nHome.latest.length, 152);
    article = f1nHome.latest[0];
    expect(article.title, 'Марко: Мы пока не знаем причин схода');
    expect(article.date, '11:39');
    expect(article.imageUrl, 'https://cdn.f1ne.ws/userfiles/marko/145212.jpg');
    expect(article.detailUrl, 'https://www.f1news.ru/news/f1-145529.html');

    article = f1nHome.latest[1];
    expect(article.title,
        'Вольфф: При ограничении зарплат важно не потерять лучших');
    expect(article.date, '10:43');
    expect(article.imageUrl, 'https://cdn.f1ne.ws/userfiles/wolff/143034.jpg');
    expect(article.detailUrl, 'https://www.f1news.ru/news/f1-145528.html');

    article = f1nHome.latest[151];
    expect(
        article.title, 'Хэмилтон: Переговоры о контракте даже не начинались');
    expect(article.date, '11:56');
    expect(
        article.imageUrl, 'https://cdn.f1ne.ws/userfiles/hamilton/145384.jpg');
    expect(article.detailUrl, 'https://www.f1news.ru/news/f1-145384.html');

    expect(f1nHome.schedule.title, 'Гран При Штирии');
    expect(f1nHome.schedule.titleDate, '10–12 июля. Шпильберг');
    expect(f1nHome.schedule.date,
        DateTime.fromMillisecondsSinceEpoch(1594558800000));
    expect(f1nHome.schedule.imageUrl,
        'https://cdn.f1ne.ws/build/images/champ/2015/australia.14cb3d69.jpg');
    expect(f1nHome.schedule.events.length, 3);
    ScheduleEvent event = f1nHome.schedule.events[0];
    expect(event.title, 'Пятница, 10 июля');
    expect(event.items.length, 3);
    ScheduleEventItem eventItem = event.items[0];
    expect(eventItem.title, '1-я тренировка');
    expect(eventItem.date, '11:55');
    eventItem = event.items[1];
    expect(eventItem.title, '2-я тренировка');
    expect(eventItem.date, '15:55');
    eventItem = event.items[2];
    expect(eventItem.title, 'Пресс-конференция');
    expect(eventItem.date, '');

    event = f1nHome.schedule.events[1];
    expect(event.title, 'Суббота, 11 июля');
    expect(event.items.length, 3);
    eventItem = event.items[0];
    expect(eventItem.title, '3-я тренировка');
    expect(eventItem.date, '12:55');
    eventItem = event.items[1];
    expect(eventItem.title, 'Квалификация');
    expect(eventItem.date, '15:50');
    eventItem = event.items[2];
    expect(eventItem.title, 'Пресс-конференция');
    expect(eventItem.date, '');

    event = f1nHome.schedule.events[2];
    expect(event.title, 'Воскресенье, 12 июля');
    expect(event.items.length, 2);
    eventItem = event.items[0];
    expect(eventItem.title, 'Стартовое поле');
    expect(eventItem.date, '');
    eventItem = event.items[1];
    expect(eventItem.title, 'Гонка');
    expect(eventItem.date, '16:00');
  });

  test('getArticle', () async {
    final dio = MockDio();
    final url = 'detailUrl';
    when(dio.get<String>(
      url,
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
      statusCode: 200,
      data: File('test/assets/f1n_article_detail.html').readAsStringSync(),
    ));

    final articleDetail = await F1nProvider(dio).getArticle(url);

    expect(articleDetail.title, 'В Renault объявили о возвращении Фернандо Алонсо');
    expect(articleDetail.date, '8 июля 2020, 14:02');
    expect(articleDetail.imageUrl, './f1n_article_detail_files/145514.jpg');
    expect(articleDetail.text.length, 7);
    expect(articleDetail.text[0], 'В среду Renault официально объявила о том, о чём говорилось последние дни  – двукратный чемпион мира Фернандо Алонсо вернется в команду в 2021 году. В следующем сезоне испанец вместе с Эстебаном Оконом будет помогать Renault готовиться к 2022 году, когда Формула 1 перейдёт на новый технический регламент.');
    expect(articleDetail.text[1], 'Фернандо Алонсо: «Renault – моя семья, и самые приятные воспоминания связаны с двумя чемпионскими титулами, но сейчас я смотрю в будущее. Меня переполняют эмоции, и я горжусь тем, что возвращаюсь в команду, которая в своё время дала мне шанс начать карьеру, а сейчас даёт возможность вернуться на самый высокий уровень.');
    expect(articleDetail.text[6], 'Кроме того, он привнесёт в нашу быстро прогрессирующую команду ту гоночную культуру, которая позволит совместными усилиями преодолеть все препятствия. Его задача – вместе с Эстебаном помочь Renault F1 Team максимально качественно подготовиться к сезону 2022 года».');
  });
}

class MockDio extends Mock implements Dio {}
