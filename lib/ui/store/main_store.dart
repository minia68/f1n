import 'package:f1n/model/f1n_home.dart';
import 'package:f1n/service/f1n_provider.dart';
import 'package:mobx/mobx.dart';

part 'main_store.g.dart';

class MainStore = _MainStore with _$MainStore;

abstract class _MainStore with Store {
  final F1nProvider f1nProvider;

  _MainStore(this.f1nProvider);

  @observable
  ObservableFuture<F1nHome> f1nFuture;

  @observable
  int screenIndex = 0;

  @action
  void fetch() {
    f1nFuture = ObservableFuture(f1nProvider.getHomePage());
  }
}