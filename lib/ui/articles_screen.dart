import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1n/model/article.dart';
import 'package:f1n/model/f1n_home.dart';
import 'package:flutter/material.dart';
import 'package:sa_stateless_animation/sa_stateless_animation.dart';
import 'package:f1n/ui/articles_detail_screen.dart';
import 'package:f1n/service/f1n_provider.dart';
import 'package:animations/animations.dart';

class ArticlesScreen extends StatefulWidget {
  final F1nHome f1nResponse;
  final F1nProvider client;
  final VoidCallback onRefresh;

  const ArticlesScreen({
    Key key,
    @required this.f1nResponse,
    @required this.client,
    @required this.onRefresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ArticlesScreenState();
}

class ArticlesScreenState extends State<ArticlesScreen> {
  int _index = 0;
  final _transitionType = ContainerTransitionType.fade;

  @override
  Widget build(BuildContext context) {
    return _buildBody(widget.f1nResponse);
  }

  Widget _buildBody(F1nHome f1nResponse) {
    final size = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Главное',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: widget.onRefresh,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: size.height * 0.3,
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
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverWidgetDelegate(Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Последние',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ),
        SliverToBoxAdapter(
          // TODO possible change to translate
          child: PlayAnimation<double>(
            duration: Duration(milliseconds: 200),
            tween: Tween(begin: 0.6, end: 0.0),
            builder: (_, __, value) => Container(
              height: size.height * value,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: _buildToday(f1nResponse.latest),
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _buildOpenContainer(
          ArticleDetailScreen(
            url: articles[i].detailUrl,
            client: widget.client,
            imageUrl: articles[i].imageUrl,
          ),
          _buildTodayItem(articles[i]),
        ),
        childCount: articles.length,
      ),
    );
  }

  Widget _buildTodayItem(Article article) {
    Widget image;
    if (article.imageUrl != null) {
      image = Card(
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
      );
    }
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: image,
      title: Text(article.title),
      trailing: Text(article.date),
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
}

class _SliverWidgetDelegate extends SliverPersistentHeaderDelegate {
  _SliverWidgetDelegate(this._widget);

  final Widget _widget;
  final _extent = 56.0;

  @override
  double get minExtent => _extent;
  @override
  double get maxExtent => _extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: _widget,
      color: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  bool shouldRebuild(_SliverWidgetDelegate oldDelegate) {
    return false;
  }
}
