// Copyright © 2022 Nevis Security AG. All rights reserved.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:nevis_mobile_authentication_sdk_example_app_flutter/domain/usecase/pause_listening_usecase.dart';
import 'package:nevis_mobile_authentication_sdk_example_app_flutter/domain/usecase/resume_listening_usecase.dart';
import 'package:nevis_mobile_authentication_sdk_example_app_flutter/getit_root.dart';
import 'package:nevis_mobile_authentication_sdk_example_app_flutter/navigation/app_navigation.dart';
import 'package:nevis_mobile_authentication_sdk_example_app_flutter/navigation/global_navigation_manager.dart';
import 'package:nevis_mobile_authentication_sdk_example_app_flutter/ui/app_state/app_bloc.dart';

late AppNavigation _appNavigation;
late GlobalNavigationManager _globalNavigationManager;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  _appNavigation = GetIt.I.get<AppNavigation>();
  _globalNavigationManager = GetIt.I.get<GlobalNavigationManager>();

  debugPrint = (message, {wrapWidth}) {
    if (!kReleaseMode) {
      debugPrintThrottled(message, wrapWidth: wrapWidth);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _pauseListeningUseCase = GetIt.I.get<PauseListeningUseCase>();
  final _resumeListeningUseCase = GetIt.I.get<ResumeListeningUseCase>();

  @override
  void initState() {
    super.initState();
    _globalNavigationManager.setNavigatorKey(_navigatorKey);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _resumeListeningUseCase.execute();
    } else if (state == AppLifecycleState.paused) {
      await _pauseListeningUseCase.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.I.get<AppBloc>(),
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        navigatorKey: _navigatorKey,
        initialRoute: AppNavigation.initialRoute,
        routes: _appNavigation.routes,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
      ),
    );
  }
}
