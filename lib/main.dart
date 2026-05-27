import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const EazeMyCargo());
}

class EazeMyCargo extends StatelessWidget {
  const EazeMyCargo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EazeMyCargo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
