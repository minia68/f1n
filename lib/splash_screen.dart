import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:f1n/articles_screen.dart';
import 'package:f1n/f1n_client.dart';
import 'package:f1n/schedule_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final client = F1nClient(Dio());
  Future<F1nResponse> f1nResponse;
  int screenIdx = 0;
  PageController pageController;

  @override
  void initState() {
    super.initState();
    f1nResponse = client.getMainPage();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<F1nResponse>(
      future: f1nResponse,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(snapshot.error.toString()),
              SizedBox(
                height: 16.0,
              ),
              RaisedButton(
                onPressed: () => f1nResponse = client.getMainPage(),
                child: Text('Refresh'),
              ),
            ],
          );
        }
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildBody(snapshot.data);
      },
    );
  }

  Widget _buildBody(F1nResponse response) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: <Widget>[
            ArticlesScreen(
              client: client,
              f1nResponse: response,
            ),
            ScheduleScreen(
              response: response,
            ),
          ],
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
        ),
      ),
      bottomNavigationBar: Card(
        color: Theme.of(context).primaryColor,
        margin: const EdgeInsets.all(0),
        elevation: 8,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildIconButton(0, 'Новости', Icons.list),
              _buildIconButton(1, 'Гонка', Icons.schedule),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(int idx, String title, IconData iconData) {
    return FlatButton.icon(
      textColor: screenIdx == idx ? Theme.of(context).accentColor : null,
      onPressed: () {
        if (screenIdx != idx) {
          setState(() {
            screenIdx = idx;
            pageController.jumpToPage(idx);
          });
        }
      },
      icon: Icon(iconData),
      label: Text(title),
    );
  }
}
