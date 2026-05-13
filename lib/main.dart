import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_strings.dart';
import 'platform/livebridge_platform.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const LiveBridgeApp());
}

class LiveBridgeApp extends StatefulWidget {
  const LiveBridgeApp({super.key});

  @override
  State<LiveBridgeApp> createState() => _LiveBridgeAppState();
}

class _LiveBridgeAppState extends State<LiveBridgeApp> {
  Locale? _localeOverride;
  String _appLanguageId = '';

  static const Color _brandSeed = Color(0xFF0D9488);

  @override
  void initState() {
    super.initState();
    _loadLocalePreference();
  }

  Future<void> _loadLocalePreference() async {
    // Persisted language selection overrides the system locale when present.
    final String raw = (await LiveBridgePlatform.getAppLanguage()).trim();
    final String normalized = raw.toLowerCase();
    if (!mounted) return;
    setState(() {
      _appLanguageId = normalized;
      _localeOverride = _localeFromId(normalized);
    });
  }

  void _handleAppLanguageChanged(String languageId) {
    setState(() {
      _appLanguageId = languageId;
      _localeOverride = _localeFromId(languageId);
    });
  }

  Locale? _localeFromId(String languageId) {
    switch (languageId) {
      case 'en':
        return const Locale('en');
      case 'fr':
        return const Locale('fr');
      default:
        return null;
    }
  }

  ThemeData _buildLightTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F7F6),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: Typography.material2021().black.apply(
        bodyColor: const Color(0xFF1A2120),
        displayColor: const Color(0xFF1A2120),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.45),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: _brandSeed,
      brightness: Brightness.light,
    );
    final ColorScheme darkColorScheme =
        ColorScheme.fromSeed(
          seedColor: _brandSeed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF67E7D9),
          onPrimary: const Color(0xFF003731),
          primaryContainer: const Color(0xFF0C5E55),
          onPrimaryContainer: const Color(0xFFA8FFF4),
          secondary: const Color(0xFF95E6DC),
          surface: const Color(0xFF0C1414),
          surfaceContainerLowest: const Color(0xFF0A1010),
          surfaceContainerLow: const Color(0xFF101A1A),
          surfaceContainer: const Color(0xFF142121),
          surfaceContainerHigh: const Color(0xFF1A2A2A),
          surfaceContainerHighest: const Color(0xFF223636),
        );

    return MaterialApp(
      title: 'LiveBridge',
      debugShowCheckedModeBanner: false,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _localeOverride,
      localeResolutionCallback: (Locale? locale, Iterable<Locale> supported) {
        if (locale == null) return supported.first;
        for (final supportedLocale in supported) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supported.first;
      },
      theme: _buildLightTheme(lightColorScheme),
      darkTheme: _buildDarkTheme(darkColorScheme),
      themeMode: ThemeMode.system,
      home: LiveBridgeHomePage(
        appLanguageId: _appLanguageId,
        onAppLanguageChanged: _handleAppLanguageChanged,
      ),
    );
  }
}
