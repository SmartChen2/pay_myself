import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/tokens.dart';
import 'theme/app_palette.dart';
import 'state/app_state.dart';
import 'state/app_state_scope.dart';
import 'i18n/strings.dart';
import 'app_shell.dart';
import 'pages/focus_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const PayMeApp());
}

class PayMeApp extends StatelessWidget {
  const PayMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    return AppStateScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final p = state.palette;
          return AppPaletteScope(
            palette: p,
            child: MaterialApp(
              onGenerateTitle: (ctx) => L10n(AppStateScope.of(ctx).effectiveLanguageCode).t('app.title'),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                brightness: p.isDark ? Brightness.dark : Brightness.light,
                scaffoldBackgroundColor: p.background,
                colorScheme: (p.isDark ? ColorScheme.dark : ColorScheme.light)(
                  primary: p.gold,
                  surface: p.background,
                  onSurface: p.foreground,
                ),
              ),
              locale: state.localeOverride == 'auto' ? null : Locale(state.localeOverride),
              supportedLocales: const [Locale('zh'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: '/',
              onGenerateRoute: (settings) {
                if (settings.name == '/focus') {
                  final args = (settings.arguments ?? {}) as Map;
                  return MaterialPageRoute<void>(
                    settings: settings,
                    fullscreenDialog: true,
                    builder: (_) => FocusPage(
                      taskId: args['taskId'] as String,
                      durationMinutes: args['duration'] as int,
                    ),
                  );
                }
                return null;
              },
              home: const AppShell(),
            ),
          );
        },
      ),
    );
  }
}
