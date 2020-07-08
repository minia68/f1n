import 'package:f1n/model/article.dart';
import 'package:f1n/model/schedule.dart';

class F1nHome {
  final List<Article> main;
  final List<Article> latest;
  final Schedule schedule;

  F1nHome({
    this.main,
    this.latest,
    this.schedule,
  });
}