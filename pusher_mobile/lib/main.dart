import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'imagineering.dart';
import 'src/base/bloc.dart';
import 'src/translations/app_translations.dart';
import 'src/constants/constants.dart';
import 'src/routes/app_pages.dart';
import 'src/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  await AppPrefs.instance.initListener();
  imagineeringSetup();
  _initialBlocs();
  bloc.Bloc.observer = AppBlocObserver();

  runApp(const App());
}

void _initialBlocs() {
  Get.put(
    AuthBloc(),
    permanent: true,
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _AppState state = context.findAncestorStateOfType<_AppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    setState(() {
      _locale = getLocale();
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    Get.find<AuthBloc>().add(const AuthLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        builder: (_, child) {
          return getx.GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splash,
            theme: AppThemes.appTheme,
            defaultTransition: getx.Transition.fadeIn,
            getPages: AppPages.pages,
            locale: _locale,
            translationsKeys: AppTranslation.translations,
          );
        },
      ),
    );
  }
}
// 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