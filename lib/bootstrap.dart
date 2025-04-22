import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/firebase_options.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Bloc.observer = AppBlocObserver();
      setUrlStrategy(PathUrlStrategy());
      runApp(await builder());
    },
    (error, stack) => log('$error', name: 'Error', stackTrace: stack),
  );
}
