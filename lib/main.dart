import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:toastification/toastification.dart';

import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => AuthService().init());

  await dotenv.load(fileName: ".env");

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  await JustAudioBackground.init(
    androidNotificationChannelId:
        'com.kalimasada.mobile_kalimasada.channel.audio',
    androidNotificationChannelName: 'Pemutaran Audio',
    androidNotificationOngoing: true,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    DevicePreview(
      enabled: !kReleaseMode && 
               const bool.fromEnvironment('HIDE_DEVICE_PREVIEW', defaultValue: false) == false,
      builder: (context) => ToastificationWrapper(
        child: GetMaterialApp(
          useInheritedMediaQuery: true,
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          title: "Application",
          theme: ThemeData(
            useMaterial3: true,
            actionIconTheme: ActionIconThemeData(
              backButtonIconBuilder: (BuildContext context) =>
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('id', 'ID')],
          locale: const Locale('id', 'ID'),
        ),
      ),
    ),
  );
}
