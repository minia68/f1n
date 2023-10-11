import 'package:dio/dio.dart';
import 'package:f1n/service/f1n_provider.dart';
import 'package:f1n/ui/store/main_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f1n/ui/screen/splash_screen.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    Get.lazyPut<MainStore>(() => MainStore(F1nProvider(Dio())));
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(),
    );
  }
}
