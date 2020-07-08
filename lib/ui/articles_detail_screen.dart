import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1n/model/article_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f1n/service/f1n_provider.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String url;
  final F1nProvider client;
  final String imageUrl;

  const ArticleDetailScreen({
    Key key,
    @required this.url,
    @required this.client,
    @required this.imageUrl,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ArticleDetailScreenState();
}

class ArticleDetailScreenState extends State<ArticleDetailScreen> {
  Future<ArticleDetail> articleDetail;

  @override
  void initState() {
    super.initState();
    articleDetail = widget.client.getArticle(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ArticleDetail>(
      future: articleDetail,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return _buildBody(
          !snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting,
          snapshot.data,
        );
      },
    );
  }

  Widget _buildBody(bool loading, ArticleDetail articleDetail) {
    Widget body;
    if (loading) {
      body = Column(
        children: <Widget>[
          _buildImage(widget.imageUrl),
          SizedBox(height: 26),
          Expanded(
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    } else {
      body = SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildImage(articleDetail.imageUrl),
            _buildTitle(articleDetail.title),
            SafeArea(
              top: false,
              child: Column(
                children: _buildText(articleDetail),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: body,
    );
  }

  Widget _buildImage(String url) {
    final width = MediaQuery.of(context).size.width;
    if (url == null) {
      return SizedBox(
        width: width,
        height: width / 1.5,
      );
    }
    return Card(
      margin: const EdgeInsets.all(0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: width,
        height: width / 1.5,
        useOldImageOnUrlChange: true,
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildText(ArticleDetail articleDetail) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(articleDetail.date),
      ),
      SizedBox(
        height: 8.0,
      ),
      for (final text in articleDetail.text)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        )
    ];
  }
}
