import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navokinotes/blocs/home_bloc.dart';
import 'package:navokinotes/blocs/login_bloc.dart';
import 'package:navokinotes/screen/login_page.dart';
import 'package:navokinotes/services/shared_preferences_services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  if (defaultTargetPlatform != TargetPlatform.android ||
      defaultTargetPlatform != TargetPlatform.iOS) {
    /// For desktop apps only
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  } else {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferencesService.instance.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LoginBloc()),
      ChangeNotifierProvider(create: (context) => HomeBloc()),
    ],
    //   create: (context) => LoginBloc(),
    child: OverlaySupport(
      child: MaterialApp(
        home: const LoginPage(),
        theme: ThemeData(
          fontFamily: 'OpenSans',
          primaryColor: Colors.deepPurple,
          primaryIconTheme: const IconThemeData(color: Colors.deepPurple),
          iconTheme: const IconThemeData(color: Colors.white),
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: const Color(0xffff470b)),
        ),
        debugShowCheckedModeBanner: false,
      ),
    ),
  ));
}
