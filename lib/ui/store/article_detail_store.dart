import 'package:f1n/model/article_detail.dart';
import 'package:f1n/service/f1n_provider.dart';
import 'package:get/get.dart';

class ArticleDetailStore extends GetxController {
  final F1nProvider f1nProvider;
  final String url;

  var _articleDetailState = _ArticleDetailState().obs;

  ArticleDetailStore(this.f1nProvider, this.url);

  ArticleDetail get articleDetail => _articleDetailState.value.articleDetail;
  bool get loading => _articleDetailState.value.loading;
  String get error => _articleDetailState.value.error;

  @override
  void onInit() {
    fetch();
  }

  Future fetch() async {
    _articleDetailState.value = _ArticleDetailState();
    try {
      _articleDetailState.value = _ArticleDetailState(
        loading: false,
        articleDetail: await f1nProvider.getArticle(url),
      );
    } catch (e, s) {
      print(e);
      print(s);
      _articleDetailState.value = _ArticleDetailState(
        loading: false,
        error: e.toString(),
      );
    }
    update();
  }
}

class _ArticleDetailState {
  final ArticleDetail articleDetail;
  final bool loading;
  final String error;

  _ArticleDetailState({this.articleDetail, this.loading, this.error});
}