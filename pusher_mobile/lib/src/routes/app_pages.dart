import 'package:get/get.dart';
import '../presentation/home/bloc/home_bloc.dart';
import '../presentation/home/home_screen.dart'; 
import '../presentation/splash/splash_screen.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      bindings: [
        BindingsBuilder.put(() => HomeBloc()),
      ],
    ), 
  ];
}

abstract class Routes {
  static const splash = '/';
  static const home = '/home'; 
}
