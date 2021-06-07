import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1n/model/article.dart';
import 'package:f1n/ui/widget/animated_pageview.dart';
import 'package:f1n/ui/widget/sliver_fixed_height_persistent_header_delegate.dart';
import 'package:f1n/ui/store/main_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f1n/ui/screen/articles_detail_screen.dart';
import 'package:animations/animations.dart';
import 'package:simple_animations/simple_animations.dart';

class ArticlesScreen extends StatelessWidget {
  final store = Get.find<MainStore>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildMainTitle(store),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: size.height * 0.3,
            child: AnimatedPageView(
              itemCount: store.f1nHome!.main.length,
              itemBuilder: (i) => _buildMainContainer(store.f1nHome!.main[i]),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverFixedHeightPersistentHeaderDelegate(
            height: 56.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Последние',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
          sliver: _buildToday(store),
        ),
      ],
    );
  }

  Widget _buildMainTitle(MainStore store) {
    return Row(
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
          onPressed: store.fetch,
        ),
      ],
    );
  }

  Widget _buildMainContainer(Article article) {
    return _buildOpenContainer(
      ArticleDetailScreen(
        url: article.detailUrl,
        imageUrl: article.imageUrl,
      ),
      _buildMainItem(article),
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
            child: article.imageUrl == null
                ? Container()
                : CachedNetworkImage(
                    imageUrl: article.imageUrl!,
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

  Widget _buildToday(MainStore store) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final article = store.f1nHome!.latest[i];
          return _buildOpenContainer(
            ArticleDetailScreen(
              url: article.detailUrl,
              imageUrl: article.imageUrl,
            ),
            _buildTodayItem(article),
          );
        },
        childCount: store.f1nHome!.latest.length,
      ),
    );
  }

  Widget _buildTodayItem(Article article) {
    Widget? image;
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
            imageUrl: article.imageUrl!,
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
      transitionType: ContainerTransitionType.fade,
      openBuilder: (_, __) => openScreen,
      tappable: true,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      closedElevation: 0.0,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      openElevation: 0,
      closedBuilder: (_, __) => closeScreen,
    );
  }
}
