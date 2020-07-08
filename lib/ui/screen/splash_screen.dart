import 'package:dio/dio.dart';
import 'package:f1n/model/f1n_home.dart';
import 'package:f1n/ui/store/main_store.dart';
import 'package:flutter/material.dart';
import 'package:f1n/ui/screen/articles_screen.dart';
import 'package:f1n/service/f1n_provider.dart';
import 'package:f1n/ui/screen/schedule_screen.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final client = F1nProvider(Dio());
  MainStore _store;

  @override
  void initState() {
    super.initState();
    _store = MainStore(client);
    _store.fetch();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Observer(
      builder: (_) {
        print('Observer');
        if (_store.f1nFuture == null ||
            _store.f1nFuture.status == FutureStatus.pending) {
          return Center(
            child: Container(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_store.f1nFuture.status == FutureStatus.rejected) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(_store.f1nFuture.error.toString()), //TODO normal message
              SizedBox(
                height: 16.0,
              ),
              RaisedButton(
                onPressed: _refresh,
                child: Text('Обновить'),
              ),
            ],
          );
        }

        return _buildBody(_store.f1nFuture.value);
      },
    );
  }

  Widget _buildBody(F1nHome response) {
    print('_buildBody');
    return Scaffold(
      body: SafeArea(
        child: Observer(
          builder: (_) => IndexedStack(
            index: _store.screenIndex,
            children: <Widget>[
              ArticlesScreen(
                client: client,
                store: _store,
              ),
              ScheduleScreen(
                schedule: response.schedule,
              ),
            ],
          ),
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
    print('_buildIconButton');
    return Observer(
      builder: (_) => FlatButton.icon(
        textColor:
            _store.screenIndex == idx ? Theme.of(context).accentColor : null,
        onPressed: () {
          if (_store.screenIndex != idx) {
            _store.screenIndex = idx;
          }
        },
        icon: Icon(iconData),
        label: Text(title),
      ),
    );
  }

  void _refresh() {
    _store.fetch();
  }
}
