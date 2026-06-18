import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async {


  await init();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

return MaterialApp.router(
  title: 'Wallety',
  theme: AppTheme.lightTheme,
  routerConfig: appRouter,
  debugShowCheckedModeBanner: false,

  useInheritedMediaQuery: true,

  locale: const Locale('ar'),

  supportedLocales: const [
    Locale('ar'),
  ],

  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],

  builder: DevicePreview.appBuilder,
);
  }
}