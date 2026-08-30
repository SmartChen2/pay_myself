import 'package:flutter/widgets.dart';
import 'app_state.dart';

/// Exposes [AppState] to the widget tree. Listeners rebuild automatically.
/// Usage: AppStateScope(state, child: MaterialApp(...)).
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  AppState get state => notifier! as AppState;

  static AppState of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppStateScope>()
        : (context.getInheritedWidgetOfExactType<AppStateScope>());
    return scope!.notifier! as AppState;
  }
}
