import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/cafe_repository.dart';
import 'providers/cafe_provider.dart';
import 'providers/settings_provider.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Web / desktop chưa cấu hình plugin notification vẫn chạy UI.
  }

  final settings = SettingsProvider();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) => CafeProvider(CafeRepository())..load(),
        ),
      ],
      child: const CafeSpotApp(),
    ),
  );
}

class CafeSpotApp extends StatefulWidget {
  const CafeSpotApp({super.key});

  @override
  State<CafeSpotApp> createState() => _CafeSpotAppState();
}

class _CafeSpotAppState extends State<CafeSpotApp> {
  late final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp.router(
      title: 'CafeSpot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: _router,
    );
  }
}
