import 'package:ahl_bader_institute/auth_screen.dart';
import 'package:ahl_bader_institute/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //تخبر الهاتف ان الفلاتر ونظام التشغيل مستعدين لتواصل مع هاردوير لهاتف
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AhlBaderInstitute());
}

class AhlBaderInstitute extends StatelessWidget {
  const AhlBaderInstitute({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ساداتنا أهل بدر الكرام',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
