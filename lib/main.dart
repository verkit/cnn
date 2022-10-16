import 'package:cnn/firebase_options.dart';
import 'package:cnn/styles/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Lung Disease Detection with VGG-16',
      home: Home(),
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(textTheme).apply(
          bodyColor: AppColor.black,
          displayColor: AppColor.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              return AppColor.primary;
            }),
            foregroundColor: MaterialStateProperty.resolveWith((states) {
              return Colors.white;
            }),
            elevation: MaterialStateProperty.resolveWith((states) {
              return 0;
            }),
          ),
        ),
      ),
    );
  }
}
