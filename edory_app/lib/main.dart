// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// NEUES Theme System und NEUER Router
import 'core/theme/avatales_theme_index.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // System UI-Konfiguration
   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  runApp(
    const ProviderScope(
      child: AvatalesApp(),
    ),
  );
}

/// Hauptanwendung - Avatales
/// Namespace: Avatales.Main
class AvatalesApp extends StatelessWidget {
  const AvatalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App-Konfiguration
      title: 'Avatales',
      debugShowCheckedModeBanner: false,
      
      // NEUES Theme System
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      
      // NEUER Router
      onGenerateRoute: AppRouter.router.onGenerateRoute,
      initialRoute: AppRouter.initialRoute,
      
      // Locale-Konfiguration
      locale: const Locale('de', 'DE'),
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Builder für zusätzliche Konfiguration
      builder: (context, child) {
        // Text-Skalierung begrenzen
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}