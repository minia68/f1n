import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sa_stateless_animation/sa_stateless_animation.dart';
import 'package:f1n/articles_detail_screen.dart';
import 'package:f1n/f1n_client.dart';
import 'package:animations/animations.dart';

class ArticlesScreen extends StatefulWidget {
  final F1nResponse f1nResponse;
  final F1nClient client;

  const ArticlesScreen({
    Key key,
    @required this.f1nResponse,
    @required this.client,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ArticlesScreenState();
}

class ArticlesScreenState extends State<ArticlesScreen>
    with AutomaticKeepAliveClientMixin<ArticlesScreen> {
  int _index = 0;
  final _transitionType = ContainerTransitionType.fade;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildBody(widget.f1nResponse);
  }

  Widget _buildBody(F1nResponse f1nResponse) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Главное',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: PlayAnimation<double>(
            tween: Tween(
              begin: size.width,
              end: 0,
            ),
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 400),
            builder: (_, child, value) => Transform.translate(
              offset: Offset(value, 0),
              child: child,
            ),
            child: _buildMain(f1nResponse.main),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Последние',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: PlayAnimation<double>(
            tween: Tween(
              begin: size.height / 2,
              end: 0,
            ),
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 400),
            builder: (_, child, value) => Transform.translate(
              offset: Offset(0, value),
              child: child,
            ),
            child: _buildToday(f1nResponse.latest),
          ),
        ),
      ],
    );
  }

  Widget _buildMain(List<Article> articles) {
    return PageView.builder(
      controller: PageController(
        viewportFraction: 0.85,
      ),
      itemCount: articles.length,
      itemBuilder: (_, i) => AnimatedPadding(
        duration: Duration(milliseconds: 400),
        padding: EdgeInsets.all(_index == i ? 0 : 12.0),
        child: _buildOpenContainer(
          ArticleDetailScreen(
            url: articles[i].detailUrl,
            client: widget.client,
            imageUrl: articles[i].imageUrl,
          ),
          _buildMainItem(articles[i]),
        ),
      ),
      onPageChanged: (int index) => setState(() => _index = index),
    );
  }

  Widget _buildMainItem(Article article) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 8,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: article.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.center,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                article.title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.fade,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToday(List<Article> articles) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: articles.length,
      itemBuilder: (_, i) => _buildOpenContainer(
        ArticleDetailScreen(
          url: articles[i].detailUrl,
          client: widget.client,
          imageUrl: articles[i].imageUrl,
        ),
        _buildTodayItem(articles[i]),
      ),
    );
  }

  Widget _buildTodayItem(Article article) {
    final image = article.imageUrl != null
        ? Card(
            margin: const EdgeInsets.all(0),
            elevation: 6,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: AspectRatio(
              aspectRatio: 1.3,
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          )
        : null;
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: image,
      title: Text(article.title),
      trailing: Text(article.content),
    );
  }

  Widget _buildOpenContainer(Widget openScreen, Widget closeScreen) {
    return OpenContainer(
      transitionType: _transitionType,
      openBuilder: (_, __) => openScreen,
      tappable: true,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      openElevation: 0,
      closedBuilder: (_, __) => closeScreen,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
