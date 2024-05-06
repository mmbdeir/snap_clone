import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snap_clone/auth_screens/choose_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:snap_clone/auth_screens/splash_screen.dart';
import 'package:snap_clone/screens/tabs.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap clone',
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.ubuntuTextTheme(),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();  
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            return const Tabs();
          }

          return const ChooseScreen();
        },
      ),
    );
  }
}