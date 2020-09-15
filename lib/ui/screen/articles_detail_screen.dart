import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1n/model/article_detail.dart';
import 'package:f1n/ui/store/article_detail_store.dart';
import 'package:f1n/ui/store/main_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:get/get.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String url;
  final String imageUrl;

  const ArticleDetailScreen({
    Key key,
    @required this.url,
    @required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArticleDetailStore>(
      global: false,
      init: ArticleDetailStore(Get.find<MainStore>().f1nProvider, url),
      builder: (store) {
        Widget body;
        if (store.error != null) {
          body = Center(
            child: Text(store.error),
          );
        } else {
          body = _buildBody(
            store.articleDetail == null || store.loading,
            store.articleDetail,
            context,
          );
        }
        return Scaffold(
          appBar: Platform.isIOS ? AppBar() : null,
          body: body,
        );
      },
    );
  }

  Widget _buildBody(
      bool loading, ArticleDetail articleDetail, BuildContext context) {
    Widget body;
    if (loading) {
      body = Column(
        children: <Widget>[
          _buildImage(imageUrl, context),
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
            _buildImage(articleDetail.imageUrl, context),
            _buildTitle(articleDetail.title),
            Text(articleDetail.date),
            SizedBox(
              height: 8.0,
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Html(
                  customRender: {
                    'a': (ctx, widget, style, elem) {
                      return Text(elem.text, style: TextStyle(fontSize: 16.0));
                    },
                    'table': (ctx, widget, style, elem) => null,
                  },
                  data: articleDetail.text,
                  style: {
                    'p': Style(
                      fontSize: FontSize(16.0),
                      textAlign: TextAlign.start,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
    return body;
  }

  Widget _buildImage(String url, BuildContext context) {
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
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
