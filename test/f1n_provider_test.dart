import 'dart:io';

import 'package:clock/clock.dart';
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
          data: (await getProjectFile('test/assets/f1n_home.html'))
              .readAsStringSync(),
        ));
    when(dio.get<String>(
      F1nProvider.rssUrl,
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
          statusCode: 200,
          data: (await getProjectFile('test/assets/f1n_news.xml'))
              .readAsStringSync(),
        ));

    final f1nProvider = F1nProvider(dio);
    final f1nHome = await withClock(
      Clock.fixed(DateTime(2020, 7, 9)),
      () => f1nProvider.getHomePage(),
    );
    expect(f1nHome.main.length, 7);
    Article article = f1nHome.main[0];
    expect(article.title, 'В Renault объявили о возвращении Фернандо Алонсо');
    expect(article.date, '');
    expect(
        article.imageUrl, 'https://cdn.f1ne.ws/userfiles/alonso/145514_sm.jpg');
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

    article = f1nHome.latest[2];
    expect(article.title, 'Гран При Штирии: Пять прямых трансляций');
    expect(article.date, '00:05');
    expect(article.imageUrl, 'https://cdn.f1ne.ws/userfiles/119347-22.jpg');
    expect(article.detailUrl, 'https://www.f1news.ru/news/f1-119347.html');

    article = f1nHome.latest[1];
    expect(article.title,
        'Вольфф: При ограничении зарплат важно не потерять лучших');
    expect(article.date, '19/12');
    expect(article.imageUrl, 'https://cdn.f1ne.ws/userfiles/wolff/143034.jpg');
    expect(article.detailUrl, 'https://www.f1news.ru/news/f1-145528.html');

    article = f1nHome.latest[151];
    expect(
        article.title, 'Хэмилтон: Переговоры о контракте даже не начинались');
    expect(article.date, '04/07');
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
          data: (await getProjectFile('test/assets/f1n_article_detail.html'))
              .readAsStringSync(),
        ));

    final articleDetail = await F1nProvider(dio).getArticle(url);

    expect(articleDetail.title,
        'В Renault объявили о возвращении Фернандо Алонсо');
    expect(articleDetail.date, '8 июля 2020, 14:02');
    expect(articleDetail.imageUrl, './f1n_article_detail_files/145514.jpg');
    expect(articleDetail.text,
        '''<p>В среду Renault официально объявила о том, о чём <a href="https://www.f1news.ru/news/f1-145480.html">говорилось</a> последние дни  – двукратный чемпион мира Фернандо Алонсо вернется в команду в 2021 году. В следующем сезоне испанец вместе с Эстебаном Оконом будет помогать Renault готовиться к 2022 году, когда Формула 1 перейдёт на новый технический регламент.</p>
<p><b>Фернандо Алонсо</b>: «Renault – моя семья, и самые приятные воспоминания связаны с двумя чемпионскими титулами, но сейчас я смотрю в будущее. Меня переполняют эмоции, и я горжусь тем, что возвращаюсь в команду, которая в своё время дала мне шанс начать карьеру, а сейчас даёт возможность вернуться на самый высокий уровень.</p>
<p>У меня есть принципы и амбиции, которые соответствуют проекту команды. Их прогресс этой зимой подтверждает возможность достижения целей, поставленных на сезон 2022 года. Я готов делиться своим гоночным опытом со всеми в команде – от инженеров до механиков и моих напарников. Команда, как и я, хочет вернуться на подиум».</p>
<p><b>Сирил Абитебул</b>, управляющий директор Renault Sport Racing: «Контракт с Фернандо Алонсо – часть долгосрочного плана компании Renault, поскольку она остаётся в Формуле&nbsp;1 и стремится вернуться  в лидеры.</p>
<p>Его присутствие станет очень важным активом для нашей команды, укрепляющим её спортивный потенциал, но также для марки Renault, к которой Фернандо очень привязан. Именно прочность этих связей, существующих между ним, командой и её болельщиками, предопределила наш естественный выбор.</p>
<p>Но это обоюдный выбор, который станет не только продолжением прошлого успешного сотрудничества – он также устремлён в будущее. Опыт Фернандо, его нацеленность на результат позволят обеим сторонам раскрыть их лучшие качества и вывести команду на тот уровень, что требуется в современной Формуле&nbsp;1.</p>
<p>Кроме того, он привнесёт в нашу быстро прогрессирующую команду ту гоночную культуру, которая позволит совместными усилиями преодолеть все препятствия. Его задача – вместе с Эстебаном помочь Renault F1 Team максимально качественно подготовиться к сезону 2022 года».</p>''');
  });
}

class MockDio extends Mock implements Dio {}

//https://stackoverflow.com/questions/58592859/reading-a-resource-from-a-file-in-a-flutter-test
Future<File> getProjectFile(String path) async {
  var dir = Directory.current;
  while (
      !await dir.list().any((entity) => entity.path.endsWith('pubspec.yaml'))) {
    dir = dir.parent;
  }
  return File('${dir.path}/$path');
}
