import 'package:f1n/model/f1n_home.dart';
import 'package:f1n/service/f1n_provider.dart';
import 'package:get/get.dart';

class MainStore extends GetxController {
  final F1nProvider f1nProvider;

  MainStore(this.f1nProvider);

  final screenIndex = 0.obs;

  final _f1nHomeState = _F1nHomeState().obs;

  F1nHome? get f1nHome => _f1nHomeState.value.f1nHome;
  bool get loading => _f1nHomeState.value.loading;
  String? get error => _f1nHomeState.value.error;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future fetch() async {
    _f1nHomeState.value = _F1nHomeState();
    update();
    try {
      _f1nHomeState.value = _F1nHomeState(
        loading: false,
        f1nHome: await f1nProvider.getHomePage(),
      );
    } catch (e, s) {
      print(e);
      print(s);
      _f1nHomeState.value = _F1nHomeState(
        loading: false,
        error: e.toString(),
      );
    }
    update();
  }
}

class _F1nHomeState {
  final F1nHome? f1nHome;
  final bool loading;
  final String? error;

  _F1nHomeState({this.f1nHome, this.loading = true, this.error});
}
