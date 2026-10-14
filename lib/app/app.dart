import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/theme_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class NotifyPanelApp extends ConsumerStatefulWidget {
  const NotifyPanelApp({super.key});

  @override
  ConsumerState<NotifyPanelApp> createState() => _NotifyPanelAppState();
}

class _NotifyPanelAppState extends ConsumerState<NotifyPanelApp> {
  late final _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Notify Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
