import 'package:f1n/ui/store/main_store.dart';
import 'package:flutter/material.dart';
import 'package:f1n/ui/screen/articles_screen.dart';
import 'package:f1n/ui/screen/schedule_screen.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  final _screens = [
    ArticlesScreen(),
    ScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    print('build');
    return GetX<MainStore>(
      builder: (store) {
        print('Observer');
        if (store.error != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(store.error), //TODO normal message
              SizedBox(
                height: 16.0,
              ),
              RaisedButton(
                onPressed: () => store.fetch(),
                child: Text('Обновить'),
              ),
            ],
          );
        }

        if (store.f1nHome == null || store.loading) {
          return Center(
            child: Container(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildBody(context, store);
      },
    );
  }

  Widget _buildBody(BuildContext context, MainStore store) {
    print('_buildBody');
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: store.screenIndex.value,
            children: _screens,
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
              _buildIconButton(context, store, 0, 'Новости', Icons.list),
              _buildIconButton(context, store, 1, 'Гонка', Icons.schedule),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, MainStore store, int idx,
      String title, IconData iconData) {
    print('_buildIconButton');
    return Obx(
      () => FlatButton.icon(
        textColor: store.screenIndex.value == idx
            ? Theme.of(context).accentColor
            : null,
        onPressed: () {
          if (store.screenIndex.value != idx) {
            store.screenIndex.value = idx;
          }
        },
        icon: Icon(iconData),
        label: Text(title),
      ),
    );
  }
}
